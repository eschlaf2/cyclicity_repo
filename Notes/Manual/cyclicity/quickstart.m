addpath([pwd '/code/']);

cd data/
processRois('Pilot*.mat');
output = analyzeCyclicity('processed_Pilot*.mat');

cyclicity_figs(output);
er = evalRatio(output);
pl = permLocations(output,5);
ph = phaseHist(output,[],[],'rois.mat');
trips = makeTriples(output,.8);