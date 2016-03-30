N = 5;

n = size(slm{1},1);
if ~exist('slm_mat','var')
    slm_mat = zeros([n,n,200]);
    for i = (1:200)
        [~,unperm] = sort(perms{i});
        slm_mat(:,:,i) = slm{i}(unperm,unperm);
    end
end

mean_slm = mean(slm_mat,3);
std_slm = std(slm_mat,[],3);

s = HWSetup();
slm_hist = cell(N,N);
[i,j] = ndgrid((1:n),(1:n));
ms = [i(:) j(:) mean_slm(:) std_slm(:)];
[~,sort_ord] = sort(ms(:,3),'descend');
sorted_ms = ms(sort_ord,:);
% centers = linspace(-500,2000,10);

for dummy_hist_ct = 1:length(ms)
    record = sorted_ms(dummy_hist_ct,:);
    i = record(1); j = record(2); m = record(3); v = record(4);
    [nelements,centers] = hist(squeeze(slm_mat(i,j,:)));
%         nelements = hist(squeeze(slm_mat(i,j,:)),centers);
    bar(centers,nelements);
    ylim([0 100])
    xlim([-3000,3000])
    fig_title = sprintf('(i,j) = (%d,%d)',i,j);
    annot_str = {sprintf('m = %3g',m); sprintf('std = %3g',v)};
    title(fig_title);
    pos = get(gca,'position');
    annotation('textbox',...
        'position',[pos(1)+.01, pos(2)+pos(4)-.11, .3, .1],...
        'string',annot_str,...
        'fitboxtotext','on','linestyle','none')
    slm_hist{i,j}.centers = centers;
    slm_hist{i,j}.nelements = nelements;
    figid = sprintf('slm_%04d_ij%02d%02d',dummy_hist_ct,i,j);
    savefig(['fig/',figid])
    hgexport(gcf,['png/',figid],s);
    close 1
end
save('slm_hist','slm_hist');