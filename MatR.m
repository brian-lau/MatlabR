% Basic class for interacting with R through RServe Java client
classdef MatR < handle
   properties
      host = 'localhost'
      port = 6311
   end
   
   properties(Dependent = true)
      isConnected
   end
   
   properties(SetAccess = private, Hidden = true)
      connection
      result
      pid
   end
      
   methods
      function self = MatR()
         self.connect();
         
         % Some R-side utilities
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
      
      function connect(self)
         import org.rosuda.REngine.Rserve.*;
         assert(exist('RConnection')==8,...
            'RServe java components not installed. Run setupMatR.');
         self.connection = RConnection(self.jstr(self.host),self.port);
         
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
      
      function wd = pwd(self)
         wd = char(self.connection.eval('getwd()').asString());
      end
      
      function list = ls(self)
         list = cell(self.connection.eval('list.files()').asStrings());
      end
      
      function source(self,path)
         assert(ischar(path),'Input must be a string');
         self.eval(['source(' path ')']);
      end
      
      function whos(self)
         msg = self.connection.eval('capture.output(lsos())');
         disp(cell(msg.asStrings));
      end
      
      function self = eval(self,expression)
         self.result = self.connection.eval(expression);
      end
      
      function voidEval(self,expression)
         self.connection.voidEval(expression);
      end
      
      function plot(self,expression)
         id = char(java.util.UUID.randomUUID.toString);
         self.eval(['jpeg("' [id '.jpg'] '",width=800,height=800,quality=100)']);
         self.voidEval(expression);
         self.voidEval('dev.off()');

         figure;
         img = imread([self.pwd filesep [id '.jpg']]);
         imshow(img);
         axis off;
         axis image;
         
         delete([self.pwd filesep [id '.jpg']]);
      end
      
      function assign(self,name,value)
         self.connection.assign(MatR.jstr(name),value);
      end
      
      function shutdown(self)
         self.connection.shutdown(); % Shutdown Rserve
         self.close();
      end
      
      function delete(self)
         self.kill();
         self.close();
         % TODO remove temp directories
      end
      
      function self = kill(self)
         import org.rosuda.REngine.Rserve.*;
         temp = RConnection();
         % SIGTERM might not be understood everywhere: so using SIGKILL signal, as well. 
         temp.eval(['tools::pskill(' num2str(self.pid) ')']); 
         temp.eval(['tools::pskill(' num2str(self.pid) ', tools::SIGKILL)']); 
         temp.close();
      end
   end
   
   methods(Static)
      % Matlab to Java strings
      function str = jstr(x)
         if iscell(x)
            n = numel(x);
            str = javaArray('java.lang.String',n);
            for j = 1:n
               str(j) = java.lang.String(x{j});
            end
         elseif ischar(x)
            str = java.lang.String(x);
         else
            error('Bad input');
         end
      end
      
      % Construct Java represention of data.frame
      function df = dataframe(x)
         import org.rosuda.REngine.*;
         l = RList;

         fn = fieldnames(x);

         switch class(x)
            case 'struct'
               % TODO: Check dimensions of each field
               for i = 1:numel(fn)
                  val = x.(fn{i});
                  switch class(val)
                     case 'categorical'
                        jsa = MatR.jstr(cellstr(val));
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
      
      % Convert Java representation to Matlab
      function result = parse(x)
         switch class(x)
            case 'org.rosuda.REngine.REXPGenericVector'
               if x.isList
                  val = x.asList();
                  fn = val.keys;
                  
                  for i = 1:numel(fn)
                     str = strrep(char(fn(i)),'.','_');
                     
                     result.(str) = MatR.parse(val.get(fn(i)));
                  end
               else
                  %?
               end
            case 'org.rosuda.REngine.REXPDouble'
               result = x.asDoubles();
            case 'org.rosuda.REngine.REXPFactor'
               result = categorical(cell(x.asStrings()));
            case 'org.rosuda.REngine.REXPInteger'
               result = x.asIntegers();
            otherwise
               error('Unrecognized class');
         end
      end
   end
end