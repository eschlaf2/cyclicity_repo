for i = 1:24
subplot(4,6,i)
imagesc(slm{i})
title(subject{i})
set(gca,'xtick',[],'ytick',[])
end
loc = strsplit(pwd,'/');
title_str = sprintf('24 sorted lead matrices\n%s - %s',...
    loc{end-1},loc{end});
annotation('textbox',[0.01 .85 .1 .05],'string',title_str,...
    'linestyle','none','horizontalalignment','center',...
    'interpreter','none')
set(gcf,'units','normalized','position',[0 0 1 1]) 
savefig('24slm')
hgexport(gcf,'24slm',HWSetup())