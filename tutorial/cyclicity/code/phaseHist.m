function [regions,counts] = phaseHist(dir_search, top_n, outid, ...
    region_names, exp_setup)
% Shows regions with consistently strong signal across all subjects by
% histogramming the number of times each region has signal strength among
% the top top_n for each subject.
% Inputs:
%   dir_search:     file name (as string) or variable name where data is
%                   stored.
%   top_n:          create histogram of top top_n phase magnitudes.
%                   (optional)
%   outid:          what to name file (optional)
%   region_names:   names of regions as a cell array or file name (as a
%                   string) containing a table with field 'regions'.
%                   (optional)
%   exp_setup:      use 'eps' or 'png' to export figures with .eps or .png
%                   extensions, respectively. (optional)
% Example:
%   [regions,counts] = phaseHist('cyclicityHCP.mat', 12, [], ...
%       'rois.mat', 'eps');

defaultTopN = 10;

if ~exist('outid','var');
    outid = [];
end

if ischar(dir_search)
    file = dir(dir_search);
    C = importdata(file.name);
    defaultOutid = file.name(1:end-4);
    if isempty(outid)
        outid = defaultOutid;
    end
else
    C = dir_search;
    defaultOutid = inputname(1);
    if isempty(outid)
        outid = defaultOutid;
    end
end

phases = C.phases;

n = numel(phases);
r = numel(phases{1});

switch nargin
    case 1
        export = false;
        top_n = defaultTopN;
    case 5
        export = true;
    otherwise
        export = false;
end

if isempty(top_n)
    top_n = defaultTopN;
end

if ~exist('region_names','var') || isempty(region_names)
    region_names = (1:r);
elseif ischar(region_names)
    region_names = importdata(which(region_names));
    region_names = region_names.regions;
    show_all = true;
end

if isnumeric(region_names)
    region_names = cellstr(num2str(region_names'));
    show_all = false;
end

out_split = strsplit(outid,'/');
if strcmp(out_split{end},'')
    out_split{end} = defaultOutid;
    outid = [outid out_split{end}];
end
  
phases_mat = abs(cell2mat(phases));
[~,sorted_phases_mat] = sort(phases_mat,1,'descend');
topn = sorted_phases_mat(1:top_n,:);
counts = hist(topn(:),(1:size(phases_mat,1)));
bar((1:r),counts./n);
xlabel('Region');
ylabel(sprintf('Appearances in top %d',top_n));
xlim([0 r+1])
if show_all
    set(gca, 'xtick',(1:r),'xticklabel',region_names)
end
view([90 90])
fig_title = sprintf('Top %d phases by phase magnitude\n%s',...
    top_n,out_split{end});
title(fig_title,'interpreter','none')
outid = [outid,'_phaseHist'];
if export
    hgexport(gcf,outid,exportSetup([],exp_setup))
end
savefig(gcf,outid)
[counts,regions] = sort(counts(:),'descend');
regions = region_names(regions);