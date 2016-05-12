function eval_ratio = evalRatio(dir_search,outid,exp_setup)
% Inputs:
%     dir_search: a cyclicity structure variable or the name of a file
%         containing such a variable (the results from analyze_cyclicity). 
%     outid:      name for the output file (can use [])
%                 default: name of data file or variable
%     expSetup:   file type for export. Use 'png' for .png, 'eps' for .eps 
%                 default = ::no export::
% Output:
%     eval_ratio: unsorted eigenvalue ratios (eval_ratio(:,i) corresponds
%                 to subject i).
% Example:
%     eratio = evalRatio('cyclicity.mat',[],'png')

switch nargin
    case 1
        outid = [];
        export = false;
    case 2
        export = false;
    case 3
        export = true;
    otherwise
        error('Wrong number of arguments')
end

if ischar(dir_search)
    file = dir(dir_search);
    C = importdata(file.name);
    if isempty(outid)
        outid = file.name(1:end-4);
    end
else
    C = dir_search;
    if isempty(outid)
        outid = inputname(1);
    end
end

evals = C.evals;
out_split = strsplit(outid,'/');
if strcmp(out_split{end},'')
    out_split{end} = 'result';
end
title_str = ['Eigenvalue ratio - ', out_split{end}];

% generate ratios
eval_mat = abs(cell2mat(evals));
eval_ratio = [eval_mat(2,:)./eval_mat(4,:);eval_mat(4,:)./eval_mat(6,:)];

% sort for plotting
plot_vals = sort(eval_ratio,2);

% generate figure
figure;
semilogy(plot_vals','*-');
maxes = max(eval_ratio,[],2)';
standards = [2 4 8 16 32];
mask1 = abs(standards - maxes(1)) < [diff(standards) 32]./3;
mask2 = abs(standards - maxes(2)) < [diff(standards) 32]./3;
standards(mask1) = maxes(1); standards(mask2) = maxes(2);
yvals = sort(unique([standards maxes]))';
set(gca,'ytick',yvals,...
    'yticklabel',num2str(yvals, 3));
grid('on')
legend({'1:2';'2:3'})
title(title_str, 'interpreter','none');
outid = [outid,'_evalRatio'];
savefig(outid)
if export
    hgexport(gcf, outid, exportSetup([],exp_setup))
end
