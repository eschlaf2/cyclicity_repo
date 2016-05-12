function [h] = cyclicity_figs(file_name,varargin)
% creates cyclicity figures for file_name (which may be the name of a file
% or a struct variable) containing variables phases, eperms, slm, evals.
% Optional inputs:
%       title:          title on slm plot and name of .fig files
%                       default: 'results'
%       row_labels:     names of processes or regions
%       export:         file extension for exporting figs ('png' or 'eps')

%% Parse input
p = inputParser;

defaultTitle = 'results';
defaultRowLabels = 0;
defaultExport = 0;

addRequired(p, 'file_name');
addParameter(p, 'title', defaultTitle);
addParameter(p, 'row_labels', defaultRowLabels);
addParameter(p,'export', defaultExport);

parse(p, file_name, varargin{:});

if ~ischar(file_name)
    C = p.Results.file_name;    
else
    file_name = p.Results.file_name;
    C = load(file_name);
    if ~exist(C.eperms,'var') 
        C.eperms = c.eperms;
    end
end

title_ = p.Results.title;
row_labels = p.Results.row_labels;
if isnumeric(row_labels)
    if row_labels == 0
        row_labels = cell(numel(C.eperms{1}),1);
        for i = (1:numel(row_labels))
            row_labels{i} = num2str(i);
        end
    else
        row_labels = cellstr(num2str(row_labels(:)));
    end
end

if ischar(p.Results.export)
    export = true;
    exp_setup = p.Results.export;
else
    export = false;
end

%% Generate plots
INTERVAL_SIZE = 20;
for set_start = (1:INTERVAL_SIZE:length(C.eperms))
    set_size = min(INTERVAL_SIZE, length(C.eperms) - set_start + 1);
    close all;
    h=zeros(1,set_size);
    for i=1:set_size
        index = set_start + i - 1;
        subj = C.subject{index};
        h(i) = figure;
        subplot(1,3,1)
        plot(.25*exp(1i*angle(C.phases{index}(C.eperms{index}))),'bo-')
        hold on;
        plot(C.phases{index}(C.eperms{index}),'g')
        plot(.25*exp(1i*angle(C.phases{index}(C.eperms{index}(1)))),'r*')
        axis([-.4, .4, -.4, .4])
        title(['Subject ',C.subject(index)]);
        axis('square')
        hold off;
        subplot(1,3,2)
        stem(abs(C.evals{index}),'b')
        C.evals{index} = abs(C.evals{index});
        eval_ratio = C.evals{index}(2)/C.evals{index}(4);
        
        title(sprintf('1:2 = %.4g', eval_ratio));
        axis('square')
        subplot(1,3,3)
        imagesc(C.slm{index})
        title([title_,' ',subj],'interpreter','none')
        set(gca,'xtick',[],'ytick',[]);
        axis('square')
        p = strjoin(strtrim(row_labels(C.eperms{index}))',' - ');
        annotation('textbox',[.05 .05 .9 .05], 'string', p, ...
            'linestyle','none','horizontalalignment','center');
        set(h(i),'units','normalized','position',[0 .5 1 .5]);
    end

    folder_name = [title_,'_figs'];
    if ~exist(folder_name,'dir')
        mkdir(folder_name)
    end

    file_name = [title_, num2str(set_start), '-', num2str(index), '.fig'];
    savefig(h,[folder_name, '/', file_name])
    if export
        s = exportSetup([],exp_setup);
        for i = 1:numel(h)
            hgexport(h(i),...
                sprintf('%s/%s_%s',folder_name,title_,subj),s);
        end
    end
end