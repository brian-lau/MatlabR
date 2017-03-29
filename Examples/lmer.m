% l = lmer;
% % Load some data R-side
% l.eval('str(sleepstudy); sleepstudy');
% % For the example, pull it into Matlab
% l.data = l.parse(l.result);
% l.call();
% l.summary();

classdef lmer < MatR
   properties
      lhs = 'Reaction'
      rhs = 'Days + (Days | Subject)'
      modName = 'test'
      data    % struct or table
   end
   
   properties(Dependent = true)
      formula % string
      beta
   end

   properties
      lib = {'lme4' 'lmerTest'}
   end

   properties(SetAccess = private, Hidden = true)
      beta_
   end
   
   methods
      function self = lmer(varargin)
         self = self@MatR();
         % Load lmer-relevant libraries
         self.library(self.lib);
      end
      
      function formula = get.formula(self)
         formula = strcat(self.modName,'<- lmer(',self.lhs,'~',self.rhs,',data=data)');
      end
      
      function beta = get.beta(self)
         beta = self.beta_;
      end
      
      function call(self)
         self.assign('data',self.dataframe(self.data));
         self.voidEval(self.formula);
         
         self.eval([self.modName '@beta'])
         self.beta_ = self.parse(self.result);
      end
      
      function summary(self)
         str = self.connection.eval(['capture.output(summary(' self.modName '))']);
         str = cell(str.asStrings());
         %if nargout == 0
            fprintf('%s\n',str{:});
         %end
      end
      
   end
end