bottList={EPZT.Al_TP_CONC_BOTTLE,EPZT.Ba_TP_CONC_BOTTLE,EPZT.Cd_TP_CONC_BOTTLE,EPZT.Co_TP_CONC_BOTTLE,...
    EPZT.Cu_TP_CONC_BOTTLE,EPZT.Fe_TP_CONC_BOTTLE,EPZT.Mn_TP_CONC_BOTTLE,...
    EPZT.Nd_TP_CONC_BOTTLE,EPZT.Ni_TP_CONC_BOTTLE,EPZT.P_TP_CONC_BOTTLE,EPZT.Pb_TP_CONC_BOTTLE,EPZT.Sc_TP_CONC_BOTTLE,...
    EPZT.Th_TP_CONC_BOTTLE,EPZT.Ti_TP_CONC_BOTTLE,EPZT.V_TP_CONC_BOTTLE,EPZT.Y_TP_CONC_BOTTLE};
pump1List={EPZT.Al_SPT_CONC_PUMP,EPZT.Ba_SPT_CONC_PUMP,EPZT.Cd_SPT_CONC_PUMP,EPZT.Co_SPT_CONC_PUMP,...
    EPZT.Cu_SPT_CONC_PUMP,EPZT.Fe_SPT_CONC_PUMP,EPZT.Mn_SPT_CONC_PUMP,...
    EPZT.Nd_SPT_CONC_PUMP,EPZT.Ni_SPT_CONC_PUMP,EPZT.P_SPT_CONC_PUMP,EPZT.Pb_SPT_CONC_PUMP,EPZT.Sc_SPT_CONC_PUMP,...
    EPZT.Th_SPT_CONC_PUMP,EPZT.Ti_SPT_CONC_PUMP,EPZT.V_SPT_CONC_PUMP,EPZT.Y_SPT_CONC_PUMP};
pump2List={EPZT.Al_LPT_CONC_PUMP,EPZT.Ba_LPT_CONC_PUMP,EPZT.Cd_LPT_CONC_PUMP,EPZT.Co_LPT_CONC_PUMP,...
    EPZT.Cu_LPT_CONC_PUMP,EPZT.Fe_LPT_CONC_PUMP,EPZT.Mn_LPT_CONC_PUMP,...
    EPZT.Nd_LPT_CONC_PUMP,EPZT.Ni_LPT_CONC_PUMP,EPZT.P_LPT_CONC_PUMP,EPZT.Pb_LPT_CONC_PUMP,EPZT.Sc_LPT_CONC_PUMP,...
    EPZT.Th_LPT_CONC_PUMP,EPZT.Ti_LPT_CONC_PUMP,EPZT.V_LPT_CONC_PUMP,EPZT.Y_LPT_CONC_PUMP};
hFig=figure('position',[58,223,1452,759]);
elemNames={'Al','Ba','Cd','Co',...
    'Cu','Fe','Mn',...
    'Nd','Ni','P','Pb','Sc',...
    'Th','Ti','V','Y'};
tempPrctileFull=99;
tempPrctileZoom=85;
gap=[0.10 0.10];margH=[0.10 0.05];margV=[0.05 0.05];

for i=1:numel(bottList)
    bott=bottList{i};
    pump1=pump1List{i};
    pump2=pump2List{i};

    subtightplot(2,2,1,gap,margH,margV);
    histogram(log10(bott./(pump1+pump2)),50);
    hLine=vline(0);
    text(0.02,0.95,'1:1 Line','color','r','Units','normalized');
    set(hLine,'LineWidth',1.5,'color','r','linestyle',':');
    xlabel(sprintf('log10(%s_{bott} / %s_{pump})',elemNames{i},elemNames{i}));

    subtightplot(2,2,2,gap,margH,margV);
    scatter(bott,pump1+pump2,30,EPZT.DEPTH_MERGE,'filled');refline(1,0);
    xlim([0 prctile(bott(bott>0),tempPrctileFull)]);
    tc=(pump1+pump2>0);ylim([0 prctile(pump1(tc)+pump2(tc),tempPrctileFull)]);
    text(0.85,0.05,'1:1 Line','Color','r','Units','normalized');
    xlabel(sprintf('%s_{bott}',elemNames{i}));
    ylabel(sprintf('%s_{pump}',elemNames{i}));
    hColorbar=colorbar;
    ylabel(hColorbar,'Depth [m]');

    subtightplot(2,2,4,gap,margH,margV);
    scatter(bott,pump1+pump2,30,EPZT.DEPTH_MERGE,'filled');refline(1,0);
    xlim([0 prctile(bott(bott>0),tempPrctileZoom)]);
    tc=(pump1+pump2>0);ylim([0 prctile(pump1(tc)+pump2(tc),tempPrctileZoom)]);
    text(0.85,0.05,'1:1 Line','Color','r','Units','normalized');
    xlabel(sprintf('%s_{bott} zoom',elemNames{i}));
    ylabel(sprintf('%s_{pump} zoom',elemNames{i}));
    hColorbar=colorbar;
    ylabel(hColorbar,'Depth [m]');

    subtightplot(2,2,3,gap,margH,margV);
    tc=bott>0 & (pump1+pump2>0);
    tempOut=prctile(bott(tc)./(pump1(tc)+pump2(tc)),[1,10,25,50,75,90,99]);
    tempCiles={'1%','10%','25%','50%','75%','90%','99%'};
    text(0,0.9,sprintf('mean: %0.3f',mean(bott(tc)./(pump1(tc)+pump2(tc)))));
    text(0,0.8,sprintf('median: %0.3f',tempOut(4)));
    for j=1:7
        text(0.2,0.9-(j+1)/10,sprintf('%s: %0.3f',tempCiles{j},tempOut(j)));
    end
saveas(hFig,sprintf('./Figures/EPZT/EPZT_BottPump_%s.png',elemNames{i}));
clf(hFig);
end
clear hFig j i tempCiles tempOut tc hLine bott pump1 pump2 hColorbar tempPrctileFull
clear elemNames tempPrctileZoom gap margH margV bottList pump1List pump2List