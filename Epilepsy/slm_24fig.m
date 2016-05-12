file = dir('cycl*quad*');
group = file.name(11:end-4);

load(file.name);

MAX = 24;
subjCt = length(slm);
indMax = min(subjCt,MAX);

figure;
for i = 1:indMax
subplot(4,ceil(indMax/4),i)
imagesc(slm{i})
title(subject{i})
set(gca,'xtick',[],'ytick',[])
end
loc = strsplit(pwd,'/');

% title_str = sprintf('%d sorted lead matrices\n%s - %s',...
%     indMax,loc{end-1},loc{end});
title_str = sprintf('%d sorted lead matrices\n%s',indMax,group);
annotation('textbox',[0.01 .85 .1 .05],'string',title_str,...
    'linestyle','none','horizontalalignment','center',...
    'interpreter','none')
set(gcf,'units','normalized','position',[0 0 .5 1]) 

outid = ['slm_',group];
savefig(outid)
hgexport(gcf,outid,HWSetup())