elemNames={'Al','Ba','Cd','Co','Cu','Fe','La','Mn','Nd','Ni','P','Pb','Sc','Th','Ti','V','Y','Zn'};
bottSuffix={"_TP_CONC_BOTTLE_nmol_kg_","_TP_CONC_BOTTLE_pmol_kg_","_TP_CONC_BOTTLE_pmol_kg_"};
pump1Suffix={"_SPT_CONC_PUMP_nmol_kg_","_232_SPT_CONC_PUMP_pmol_kg_","_SPT_CONC_PUMP_pmol_kg_"};
pump2Suffix={"_LPT_CONC_PUMP_nmol_kg_","_LPT_CONC_PUMP_pmol_kg_","_LPT_CONC_PUMP_pmol_kg_"};
hFig=figure('position',[58,223,1452,759]);
tempPrctileFull=99;
tempPrctileZoom=85;
gap=[0.10 0.10];margH=[0.10 0.05];margV=[0.05 0.05];

cruiseCats = {'GA01';'GA03';'GN01';'GP16'};
% Initialize a table to store median and stdev for each element and cruise
medianAndStdevByElemAndCruise = table('Size',[0 4], ...
    'VariableTypes',{'string','string','double','double'}, ...
    'VariableNames',{'Cruise','Element','Median','Stdev'});

for j = 1:numel(cruiseCats)
    % For each cruise, select rows matching this cruise
    cruise = cruiseCats{j};
    cruiseMask = strcmp(cellstr(allMerge.Cruise), cruise);

    for i = 1:numel(elemNames)
        elemName = elemNames{i};
        % Try both possible suffixes for each field
        bottField = '';
        pump1Field = '';
        pump2Field = '';
        for s = 1:numel(bottSuffix)
            bf = sprintf('%s%s', elemName, bottSuffix{s});
            pf1 = sprintf('%s%s', elemName, pump1Suffix{s});
            pf2 = sprintf('%s%s', elemName, pump2Suffix{s});
            if all(ismember({bf, pf1}, allMerge.Properties.VariableNames))
                bottField = bf;
                pump1Field = pf1;
                pump2Field = pf2;
                break;
            end
        end

        % Only proceed if all fields exist
        if isempty(bottField) || isempty(pump1Field)
            continue;
        end

        % Select data for this cruise and element
        bott = allMerge.(bottField)(cruiseMask);
        pump1 = allMerge.(pump1Field)(cruiseMask);
        pump2 = allMerge.(pump2Field)(cruiseMask);
        depth = allMerge.("DEPTH_m_")(cruiseMask);
        stn = removecats(allMerge.('Station_METAVAR_INDEXED_TEXT')(cruiseMask));

        % Check that each field has data
        if ~sum(~isnan(bott)) || ~sum(~isnan(pump1))
            continue;
        end

        bott(bott<=0)=NaN;
        pump1(pump1<=0)=NaN;
        pump2(pump2<=0)=NaN;
        pumpsum=sum([pump1,pump2],2,'omitnan');
        pumpsum(pumpsum==0)=NaN;
        bottpumpRatio=bott./pumpsum;
        bottpumpRatio(bottpumpRatio<=0)=NaN;

        subtightplot(2,2,1,gap,margH,margV);
        histogram(log10(bottpumpRatio),50);
        hLine=vline(0);
        text(0.02,0.95,'1:1 Line','color','r','Units','normalized');
        set(hLine,'LineWidth',1.5,'color','r','linestyle',':');
        xlabel(sprintf('log10(%s_{bott} / %s_{pump})',elemNames{i},elemNames{i}));

        subtightplot(2,2,2,gap,margH,margV);
        scatter(bott,pumpsum,30,depth,'filled');refline(1,0);
        xlim([0 prctile(bott,tempPrctileFull)]);
        ylim([0 prctile(pumpsum,tempPrctileFull)]);
        text(0.85,0.05,'1:1 Line','Color','r','Units','normalized');
        xlabel(sprintf('%s_{bott}',elemNames{i}));
        ylabel(sprintf('%s_{pump}',elemNames{i}));
        hColorbar=colorbar;
        colormap parula;
        ylabel(hColorbar,'Depth [m]');

        subtightplot(2,2,4,gap,margH,margV);
        scatter(bott,pumpsum,30,depth,'filled');refline(1,0);
        xlim([0 prctile(bott,tempPrctileZoom)]);
        ylim([0 prctile(pumpsum,tempPrctileZoom)]);
        text(0.85,0.05,'1:1 Line','Color','r','Units','normalized');
        xlabel(sprintf('%s_{bott} zoom',elemNames{i}));
        ylabel(sprintf('%s_{pump} zoom',elemNames{i}));
        hColorbar=colorbar;
        colormap parula;
        ylabel(hColorbar,'Depth [m]');

        subtightplot(2,2,3,gap,margH,margV);
        tempOut=prctile(bottpumpRatio,[1,10,25,50,75,90,99]);
        tempCiles={'1%','10%','25%','50%','75%','90%','99%'};
        text(0,0.9,sprintf('mean: %0.3f',mean(bottpumpRatio,'omitnan')));
        text(0,0.8,sprintf('median: %0.3f',tempOut(4)));
        for k=1:7
            text(0.2,0.9-(k+1)/10,sprintf('%s: %0.3f',tempCiles{k},tempOut(k)));
        end
        saveas(hFig,sprintf('./Figures/%s/%s_BottPump_%s.png',cruise,cruise,elemNames{i}));

        % Save median and stdev for this cruise and element
        medianVal = tempOut(4);
        stdevVal = std(bottpumpRatio,'omitnan');
        medianAndStdevByElemAndCruise = [medianAndStdevByElemAndCruise; ...
            {cruise, elemName, medianVal, stdevVal}];
        clf(hFig);

        tc=~isnan(bottpumpRatio);
        scatter(stn(tc),-depth(tc),80,log10(bottpumpRatio(tc)),'filled','markeredgecolor','k');
        applyWhiteCenteredColormap_staticCaxis();
        title(sprintf('%s - %s',cruise,elemNames{i}));
        hColorbar=colorbar;
        ylabel(hColorbar,sprintf('log_{10} bott/pump ratio, %s',elemNames{i}));
        saveas(hFig,sprintf('./Figures/%s/%s_BottPump_%s_Map.png',cruise,cruise,elemNames{i}));
        ylim([-1000 0]);
        saveas(hFig,sprintf('./Figures/%s/%s_BottPump_%s_Map_shallow.png',cruise,cruise,elemNames{i}));
        clf(hFig);
    end
end
close(hFig);

% Clear all temporary variables except the output table
clear hFig j i tempCiles tempOut tc hLine bott pump1 pump2 hColorbar tempPrctileFull
clear elemNames tempPrctileZoom gap margH margV bottField pump1Field pump2Field
clear cruise cruiseCats cruiseMask elemName s bf pf1 pf2 depth ratioVals medianVal stdevVal
clear pump1Suffix pump2Suffix cruises bottSuffix pumpsum k bottpumpRatio stn hColorbar