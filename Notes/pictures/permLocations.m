file = dir('cyclicity_all_resting.mat');
load(file.name);
group = file.name(11:end-4);
n = numel(perms);
r = numel(perms{1});
perms_mat = cell2mat(perms');
perm_locs = cell2mat(arrayfun(@(x) sum(perms_mat == x)./n, ...
    (1:r)','uniformoutput',0));
imagesc(perm_locs);
colormap(gray(4));
colorbar
% loc = strsplit(pwd,'/');
% title_str = sprintf(...
%     'Percent of appearances in permutation locations\n%s - %s (n=%d)',...
%     loc{end-1},loc{end},n);
title_str = sprintf(...
    'Percent of appearances in permutation locations\n%s', group);
%     f.name,'preictal',n);
title(title_str,'interpreter','none');
xlabel('Permutation location');
ylabel('Region');
outid = ['perm_locations',file.name(11:end-4)];
savefig(outid);
hgexport(gcf,outid,HWSetup());