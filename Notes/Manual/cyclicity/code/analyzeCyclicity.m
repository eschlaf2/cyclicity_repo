% function [phases, eperms, slm, evals] = ...
function [cyclicity] = ...
    analyze_cyclicity(dir_search, lineFilter, timeFilter, field)
% Returns cyclicity results for dir_search file in current
% directory. Saves results in 'cyclicity.mat'. The input 
% dir_search should be a string regular expression for a (set of) .mat 
% file(s) containing time series data stored row wise, or it can be an 
% array variable. If dir_search is a string, the unique subject id is 
% assumed to be the field immediately preceding '.mat' in the file name.
% Inputs:
%   dir_search:     regular expression for files to be analyzed
%   lineFilter:     which lines to use from data (can use [])
%                   (default: all)
%   timeFilter:     which time intervals to use (can use [])
%                   (default: all)
%   field:          if the given files are saved as structs, field
%                   indicates which field of the struct contains the data
%                   (default: 'data')
% Example:          (analyze even numbered regions at time steps 10-20)
%   output = analyze_cyclicity('processed_subject*.mat',...
%       [2:2:33], (10:20));

%% Parse
defaultLines = 'a';
defaultTimes = 'a';
defaultField = 'data';

switch nargin
    case 1
        lineFilter = defaultLines;
        timeFilter = defaultTimes;
        field = defaultField;
    case 2
        timeFilter = defaultTimes;
        field = defaultField;
    case 3
        if isempty(lineFilter)
            lineFilter = defaultLines;
        end
        field = defaultField;
    case 4
        if isempty(lineFilter)
            lineFilter = defaultLines;
        end
        if isempty(timeFilter)
            timeFilter = defaultTimes;
        end
    otherwise
        error('Wrong number of arguments')
end
  
if ischar(dir_search)
    files = dir(dir_search);
else
    if iscell(dir_search)
        files = dir_search;
    elseif isnumeric(dir_search)
        files = {dir_search};
    else
        error(['dir_search should be the name of a file, ', ...
            'a single matrix or a cell array containing matrices.']);
    end
end

%% Main
n = length(files);
phases = cell(1,n); eperms = cell(1,n); slm = cell(1,n); evals = cell(1,n); 
subject = cell(1,n);
i = 1;
for file = files(:).'
    
    % get data
    if ~ischar(dir_search)
        data_file = file{1};
        sbj = {num2str(i)};
        sbjInd = 1;
    else
        data_file = importdata(file.name);
        sbj = strsplit(file.name,{'_','.'},'Collapsedelimiters',true);
        sbjInd = length(sbj)-1;
    end
    if isstruct(data_file)
        data_file = data_file.(field);
    end
    
    % apply filters
    if ~ischar(lineFilter)
        data_file = data_file(lineFilter,:);
    end
    if ~ischar(timeFilter)
        data_file = data_file(:,timeFilter);
    end
    
    % get and print subject (show progress)
    subject{i} = sbj{sbjInd};
    fprintf('%s\n',subject{i});
    
    % analysis
    [phases{i}, eperms{i}, slm{i}, evals{i}] = ...
        cyclic_analysis(data_file);
    i = i + 1;
end

save('cyclicity.mat', ...
    'phases', 'eperms','slm','evals','subject');

cyclicity = struct();
cyclicity.phases = phases;
cyclicity.evals = evals;
cyclicity.eperms = eperms;
cyclicity.slm = slm;
cyclicity.subject = subject;

fprintf('Done\n');
