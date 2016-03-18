N = 33;

if ~exist('slm_mat','var')
    slm_mat = zeros(33,33,200);
    for i = (1:200)
        [~,unperm] = sort(perms{i});
        slm_mat(:,:,i) = slm{i}(unperm,unperm);
    end
end

mean_slm = mean(slm_mat,3);

s = HWSetup();
slm_hist = cell(N,N);
% centers = linspace(-500,2000,10);
for i = (1:N-1)
    for j = (i+1:N)
        [nelements,centers] = hist(squeeze(slm_mat(i,j,:)));
%         nelements = hist(squeeze(slm_mat(i,j,:)),centers);
        bar(centers,nelements);
        ylim([0 100])
        xlim([-3000,3000])
        title(['(i,j) = (',num2str(i),',',num2str(j),')']);
        slm_hist{i,j}.centers = centers;
        slm_hist{i,j}.nelements = nelements;
        figid = ['slm_ij',num2str(i,'%02d'),num2str(j,'%02d')];
        savefig(['fig/',figid])
        hgexport(gcf,['png/',figid],s);
    end
end
save('slm_hist','slm_hist');