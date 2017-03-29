l = lmer;
% Load some data R-side
l.eval('str(sleepstudy); sleepstudy');
% For the example, pull it into Matlab
l.data = l.parse(l.result);
l.call();
l.summary();