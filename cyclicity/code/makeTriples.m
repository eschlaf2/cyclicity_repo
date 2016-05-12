function trips = makeTriples(dir_search, thresh, outid, region_names, ...
    exp_setup)
% Shows regions with consistently strong signal across all subjects by
% histogramming the number of times each region has signal strength among
% the top top_n for each subject.
% Inputs:
%   dir_search:     file name (as string) or variable name where data is
%                   stored.
%   thresh:         a number between 0 and 1 - extract triples that appear 
%                   in at least threshs portion of subjects. (optional)
%   outid:          what to name file (optional)
%   region_names:   names of regions as a cell array or file name (as a
%                   string) containing a table with field 'regions'.
%                   (optional)
%   exp_setup:      use 'eps' or 'png' to export figures with .eps or .png
%                   extensions, respectively. (optional)
% Example:
%   trips = makeTriples('cyclicityHCP.mat', .7, [], ...
%       'rois.mat', 'eps');

defaultThresh = .5;

if ~exist('outid','var');
    outid = [];
end

if ischar(dir_search)
    files = dir(dir_search);
    defaultOutid = files(1).name(1:end-4);
elseif iscell(dir_search)
    files = [];
    for i = 1:numel(dir_search)
        files = [files;dir(dir_search{i})];
    end
    defaultOutid = files(1).name(1:end-4);
else
    files = -1;
    defaultOutid = inputname(1);
end

if isempty(outid)
    outid = defaultOutid;
end

switch nargin
    case 1
        export = false;
        thresh = defaultThresh;
    case 5
        if ischar(exp_setup)
            export = true;
        else 
            export = false;
        end
    otherwise
        export = false;
end

if isempty(thresh)
    thresh = defaultThresh;
end

out_split = strsplit(outid,'/');
if strcmp(out_split{end},'')
    out_split{end} = defaultOutid;
    outid = [outid out_split{end}];
end

CYCLE = true; % changing this will require a fix in maketrips.
CREATE_TRIP_FILE = true;
STYLE = 'rbkmcg';

figs_out_file = [outid,'_makeTriples'];

lgnd = cell(numel(files),1);
s = 1;

make_figs = (export || numel(files) > 1);

if make_figs
    figure;
end
trips = cell(numel(files),1);
for file = files'
    if isnumeric(file)
        try
            eperms = dir_search.perms;
        catch
            eperms = dir_search.eperms;
        end
        filename = inputname(1);
    elseif isstruct(file)
        C = importdata(file.name);
        try
            eperms = C.perms;
        catch
            eperms = C.eperms;
        end
        filename = file.name(1:end-4);
    end
    
    r = length(eperms{1});
    n = length(eperms);
    
    if ~exist('region_names','var') || isempty(region_names)
        region_names = (1:r);
    elseif ischar(region_names)
        region_names = importdata(which(region_names));
        region_names = region_names.regions;
    end
    
    if isnumeric(region_names)
        if region_names == -1
            region_names = cellstr(num2str((1:r)'));
        else
            region_names = cellstr(num2str(region_names'));
        end
    end
    
    triples = maketrips(eperms,CYCLE);

    trips{s} = triples(triples(:,4)>=thresh*n,:);
        
    coord_ct = size(trips{s},1);
    
    fprintf('%s: %d triples using given threshold\n',filename,coord_ct);
 
    if make_figs
        ms = (length(files) + 1 - s)*4;
        pl = @() plotMake(trips{s},r,STYLE(s),ms);

        subplot(1,5,1);
        pl();
        view(2);

        subplot(1,5,2);
        pl();
        view(0,0)

        subplot(1,5,3);
        pl();
        view(90,0);

        subplot(1,5,4:5)
        pl();
        title(out_split{end},'interpreter','none')
    end
    
    % create triples files
    if CREATE_TRIP_FILE
        outname = sprintf('%s_makeTriples_thresh%02g',...
            filename,round(thresh*100));
        fileID = fopen([outname,'.txt'],'w');
        fprintf(fileID,'%s\nTotal subjects: %d\n',pwd,n);
        for i = (1:size(trips,1))
            x = strtrim(region_names{trips{s}(i,1)});
            y = strtrim(region_names{trips{s}(i,2)});
            z = strtrim(region_names{trips{s}(i,3)});
            w = trips{s}(i,4);
            fprintf(fileID,'%s,%s,%s,%d\n',x,y,z,w);
        end
        fclose(fileID);
        save(figs_out_file,'trips');
    end
    
    lgnd{s} = filename;
    s = s+1;
end

set(gcf,'units','normalized','position',[0 .5 1 .5])
if numel(files) > 1
    legend(lgnd,'interpreter','none');
end
clear s

if make_figs
    savefig(1,figs_out_file);
end

if export
    hgexport(gcf,figs_out_file,exportSetup([],exp_setup));
end

end

function [trips] = maketrips(eperms, CYCLE)

n = length(eperms{1});
r = numel(eperms);
trips = zeros(n,n,n);
[a, b, c] = ndgrid(1:n, 1:n, 1:n);

for p = 1:r
    perm = eperms{p};
    
    for i = (1:n-2)
        for j = (i+1:n-1)
            wheel = [perm;circshift(perm,-i,2);circshift(perm,-j,2)];
            new_trips = wheel(:,1:end-j)';
            if CYCLE
                new_trips = cycle_trips(new_trips);
            end
            inds = sub2ind(size(trips),...
                new_trips(:,1), new_trips(:,2), new_trips(:,3));
            trips(inds) = trips(inds) + 1;
        end
    end
end
trips = [a(:) b(:) c(:) trips(:)];
[~,s4] = sort(trips(:,4),'descend');
trips = trips(s4,:);

if mod(r,2)
    trips = trips(1:(length(trips)-1)/2,:);
else
    st_mids = find(trips(:,4)==r/2,1,'first');
    end_mids = find(trips(:,4)==r/2,1,'last');
    mids = trips(st_mids:end_mids,:);
    mask = mids(:,2) < mids(:,3);
    mids = mids(mask,:);
    trips = [trips(1:st_mids-1,:);mids];
end
        
end

function plotMake(trips,r,style,ms)

plot3(trips(:,1),trips(:,2),trips(:,3),...
        [style,'o'],'markersize',ms,'linewidth',2);
    xlabel('1'); ylabel('2'); zlabel('3');
    axis([1 r 1 r 1 r])
    grid('on');
    hold on;
end

function [trips] = cycle_trips(trips)
[~,min_loc] = min(trips(:,1:3),[],2);
shift = mod([min_loc,min_loc+1,min_loc+2] - 1, 3) + 1;
for i =(1:size(trips,1))
    trips(i,1:3) = trips(i,shift(i,:));
end
end