n = numel(perms);
r = numel(perms{1});
perms_mat = cell2mat(perms');
perm_locs = cell2mat(arrayfun(@(x) sum(perms_mat == x)./n, ...
    (1:r)','uniformoutput',0));
imagesc(perm_locs);
colormap(gray(4));
colorbar
loc = strsplit(pwd,'/');
title_str = sprintf(...
    'Percent of appearances in permutation locations\n%s - %s (n=%d)',...
    loc{end-1},loc{end},n);
%     f.name,'preictal',n);
title(title_str,'interpreter','none');
xlabel('Permutation location');
ylabel('Region');
savefig('perm_locations');
hgexport(gcf,'perm_locations',HWSetup());