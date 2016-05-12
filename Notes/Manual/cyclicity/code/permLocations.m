function perm_locs = permLocations(dir_search,num_clusters,outid,...
    region_names, exp_setup)
% Visualizes where in the permutation each region falls given permutations
% from multiple subjects.
% Inputs:
%   dir_search:     file name (as string) or variable name where data is
%                   stored.
%   numClusters:    agglomerates regions into num_clusters groups; plots
%                   imagesc with num_clusters gray values. (optional)
%   outid:          what to name file (optional)
%   region_names:   names of regions as a cell array or file name (as a
%                   string) containing a table with field 'regions'.
%                   (optional)
%   exp_setup:      use 'eps' or 'png' to export figures with .eps or .png
%                   extensions, respectively. (optional)
% Example:
%   pl = permLocations('cyclicityHCP.mat',5,[],'rois.mat','eps');

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

try 
    perms = C.perms;
catch
    perms = C.eperms;
end

n = numel(perms);
r = numel(perms{1});

defaultNumClusters = floor(r/3);

switch nargin
    case 1
        export = false;
        num_clusters = defaultNumClusters;
    case 5
        export = true;
    otherwise
        export = false;
end

if isempty(num_clusters)
    num_clusters = defaultNumClusters;
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
title_str = ['Permutation location distribution - ', out_split{end}];
    
perms_mat = cell2mat(perms');
perm_locs = cell2mat(arrayfun(@(x) sum(perms_mat == x)./n, ...
    (1:r)','uniformoutput',0));
[plot_vals,widths] = clusterLoc(perm_locs,num_clusters);

exportSetup(num_clusters);

figure(90);
plot(accordion(plot_vals),'.','markersize',20);
plotSetup(r,widths,region_names,title_str,show_all);

figure(91);
bar(plot_vals,'stack');
plotSetup(r,widths,region_names,title_str,show_all);

figure(92);
imagesc(perm_locs);
colormap(gray(num_clusters));
colorbar

title_str = sprintf(...
    'Proportion of appearances in permutation locations\n%s', out_split{end});
title(title_str,'interpreter','none');
if show_all
    set(gca,'ytick', 1:r,'yticklabel',region_names);
end
xlabel('Permutation location');
ylabel('Region');

figure(93);
plot(std(perm_locs,[],2),'b.','markersize',20)
plotSetup(r,widths,region_names,title_str,show_all,false);
ylabel('Standard deviation')

outid = [outid,'_permLocations'];
savefig(90,[outid,'dots']);
savefig(91,[outid,'bars']);
savefig(92,[outid,'gray']);
savefig(93,[outid,'std']);
if export
    s = exportSetup(num_clusters,exp_setup);
    hgexport(90,[outid,'dots'],s);
    hgexport(91,[outid,'bars'],s);
    hgexport(92,[outid,'gray'],s);
    hgexport(93,[outid,'std'],s);
end
end

function [output,widths] = clusterLoc(input,numClusters)

[rows,cols] = size(input);

extra = mod(cols,numClusters);
widths = floor(cols/numClusters)*ones(1,numClusters);
for i = 1:extra
    if mod(i,2)
        ind = (i+1)/2;
        widths(ind) = widths(ind) + 1;
    else
        ind = i/2;
        widths(end-ind+1) = widths(end-ind+1) + 1;
    end
end
        
output = zeros(rows,numClusters);

start = 1;
for i = 1:numClusters
    cs = start;
    cf = start+widths(i)-1;
    output(:,i) = sum(input(:,cs:cf),2);
    start = start + widths(i);
end

end

function input = accordion(input)

offset = .01;
[r,c] = size(input);

for i=1:r
    row_vals = unique(input(i,:));
    while length(row_vals) ~= c
        for j=1:length(row_vals)
            mask = input(i,:) == row_vals(j);
            if sum(mask) == 1
                continue
            else
                input(i,mask) = offset*(0:sum(mask)-1)+row_vals(j);
            end
        end
        row_vals = unique(input(i,:));
    end
end           
        
end

function [] = plotSetup(r,widths,regionNames,title_str,...
    show_all,show_legend)
view(90,90);
if ~exist('show_legend','var')
    show_legend = true;
end
axis('tight')
starts = cumsum([1; widths(:)]);
if show_legend
    lgnd = ...
        arrayfun(@(s,f) sprintf('%d-%d',s,f),...
        starts(1:end-1),starts(2:end)-1,...
        'UniformOutput',false);
    legend(lgnd);
end
if show_all
    set(gca, 'xtick', 1:r,'xticklabel', regionNames);
end
grid('on')
xlabel('Region');
ylabel('Proportion');
title(title_str,'interpreter','none');
end
    
