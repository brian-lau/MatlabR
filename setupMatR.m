% Not sufficient that these classes are in the dynamic path
function setupMatR()

jpath = javaclasspath('-static');
[~,jars] = cellfun(@(x) fileparts(x),jpath,'uni',0);

if any(strcmp(jars,'REngine')) && any(strcmp(jars,'RserveEngine'))
   % Already in user's static javaclasspath
else
   path = fileparts(which('MatR'));
   
   % TODO, check existence, download otherwise
   javaaddpathstatic([path filesep 'lib/REngine.jar']);
   javaaddpathstatic([path filesep 'lib/RserveEngine.jar']);
end