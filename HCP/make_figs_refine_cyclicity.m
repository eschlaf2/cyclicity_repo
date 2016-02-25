!mv refine_cyclicity_output.mat refine_cyclicity_output_FIND_n5.mat
load refine_cyclicity_output_FIND_n5
for i = 1:3
figure(1)
subplot(1,3,i)
perm = [out_perm{:,i}];
hist(perm(:),(1:max(cell2mat(out_perm(:)))));
title(['Group ',num2str(i)])
axis('tight')
xlabel('roi')
ylabel('pax')
figure(2)
subplot(1,3,i)
evals = [eval_ratio{:,i}];
plot(evals(:),'b.');
title(['Group ',num2str(i)])
axis('tight')
xlabel('subject')
ylabel({'eval ratio', [num2str(min(evals(:)),2),'-',num2str(max(evals(:)),3)]})
end