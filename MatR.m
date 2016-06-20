% Basic class for interacting with R through RServe
classdef MatR < handle
   properties (SetAccess = private)
      connection
      result
      pid
   end
   
   properties (Dependent = true)
      isConnected
   end
      
   methods
      function self = MatR()
         try
            import org.rosuda.REngine.*;
            import org.rosuda.REngine.Rserve.*;
         catch
            
         end
         
         self.connect();
         path = fileparts(which('MatR'));
         self.source(['"' path filesep 'utils.R' '"']);
      end
      
      function isConnected = get.isConnected(self)
         try
            isConnected = self.connection.isConnected();
         catch
            isConnected = false;
         end
      end
      
      function connect(self,host,port)
         import org.rosuda.REngine.Rserve.RConnection;
         self.connection = RConnection();
         
         fprintf(1,'%s\n',self.Rversion);
         
         % Determine PID in case we need to kill
         self.pid = self.connection.eval('Sys.getpid()').asInteger();
      end
      
      function self = close(self)
         self.connection.close();
      end
      
      function ver = Rversion(self)
         ver = self.connection.eval('R.version.string');
         ver = char(ver.asString());
      end

      function library(self,lib)
         if iscell(lib)
            for i = 1:numel(lib)
               self.connection.eval(['library(' lib{i} ')']);
            end
         elseif ischar(lib)
            self.connection.eval(['library(' lib ')']);
         else
            error('Invalid library specification');
         end
      end
      
      function list = packages(self)
         %list = self.connection.eval('(.packages())');
         list = self.connection.eval(['capture.output(' ...
            'for (package_name in sort(loadedNamespaces())) {'...
            'print(paste(package_name, packageVersion(package_name)))})']);
         list = cell(list.asStrings);
      end
      
      function source(self,path)
         assert(ischar(path),'Input must be a string');
         self.eval(['source(' path ')']);
      end
      
      function whos(self)
         msg = self.connection.eval('capture.output(lsos())');
         disp(cell(msg.asStrings));
      end
      
      function eval(self,expression)
         self.result = self.connection.eval(expression);
      end
      
      function delete(self)
         self.kill();
         self.close();
      end
      
      function self = kill(self)
         import org.rosuda.REngine.Rserve.RConnection;
         temp = RConnection();
         % SIGTERM might not be understood everywhere: so using SIGKILL signal, as well. 
         temp.eval(['tools::pskill(' num2str(self.pid) ')']); 
         temp.eval(['tools::pskill(' num2str(self.pid) ', tools::SIGKILL)']); 
         temp.close();
      end
   end
   
   methods(Static)
      
      % Construct Java represenation of data.frame
      function df = dataframe(x)
         import org.rosuda.REngine.*;
         l = RList;

         fn = fieldnames(x);

         switch class(x)
            case 'struct'
               for i = 1:numel(fn)
                  val = x.(fn{i});
                  switch class(val)
                     case 'categorical'
                        valstr = cellstr(val);
                        n = numel(val);
                        jsa = javaArray('java.lang.String',n);
                        for j = 1:n
                           jsa(j) = java.lang.String(valstr{j});
                        end
                        val = REXPFactor(RFactor(jsa));
                     case 'char'
                     case {'double'}
                        val = REXPDouble(val);
                  end
                  l.put(java.lang.String(fn{i}),val);
               end
         end
         
         df = REXP().createDataFrame(l);
      end
   end
end