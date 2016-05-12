function processRois(dir_search,radius,roi_file)
% Will process files matching string regular expression dir_search.
% Results will be saved as
% 'processed_*.mat'. Returns mean value of points within specified
% radius of ROIS indicated in rois.mat file.
% Inputs: 
%     dir_search: regular expression matching file names to be processed. 
%                 Should be entered as a string. (required)
%     radius:     radius of sphere around central point of region in
%                 coordinate units. (optional)
%                 default = 5
%     roiFile:    a table variable in the workspace with columns 'coords' 
%                 and 'regions' or the name of a file on the search path 
%                 (as a string) containing a table variable.
%                 default = 'rois.mat'
% Example:  
%     processRois('Pilot*.mat',[],'otherRois.mat');


%% Parse input
files = dir(dir_search);
if nargin==1
    radius = 5;
    roi_file = 'rois.mat';
elseif nargin==2
    roi_file = 'rois.mat';
elseif nargin==3
    if isempty(radius)
        radius = 5;
    end
else 
    error('Wrong number of arguments')
end

if ischar(roi_file)
    rois = importdata(which(roi_file));
else
    rois = roi_file;
end

fn = unique(fieldnames(rois));
if ~strcmpi(fn,{'Properties';'coords';'regions'})
    error(['Contents of roiFile should be a table with columns ',...
        '''coords'' and ''regions''']);
end

%% Verify names
names = {files.name};
ids = cell(size(names));
for i = 1:length(names)
    id = strsplit(names{i},{'.','_'});
    ids{i} = id{end-1};
end
if length(unique(ids)) ~= length(names)
    warning(['Subject id will not be unique after analyze_cyclicity. ',...
        'Unique subject id should immediately precede file extension.']);
end

%% Main
for file = files.'
    try
        data = importdata(file.name);
    catch 
        warning(strcat(file.name,' did not load properly.'))
        continue
    end
    
    c = size(data,2);
    r = height(rois);
    sub_rois = zeros(r, c - 3);
    for i = 1:r
        filename = strcat('processed_', file.name);
        try
            coords = rois.coords(i,:);
        catch 
            coords = rois.Coords(i,:);
        end
        xyzMask = ...
            abs(data(:,1:3) - repmat(coords, size(data,1),1)) <= radius;
        mask = (sum(xyzMask,2) == 3);
        sub_rois(i,:) = mean(data(mask,4:end));
    end
    save(filename,'sub_rois')
    clear data sub_rois;
end

