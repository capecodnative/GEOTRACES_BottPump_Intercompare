function sapToUcctdMap = manual_SAP_UCCTD_matching(CruiseBottPump, ucctdTag, sapTag)
    stations = unique(CruiseBottPump.Station_METAVAR_INDEXED_TEXT);

    isUCCTD = CruiseBottPump.SamplingDevice_INDEXED_TEXT == ucctdTag;
    isSAP   = CruiseBottPump.SamplingDevice_INDEXED_TEXT == sapTag;

    ucctdTbl = CruiseBottPump(isUCCTD, :);
    sapTbl   = CruiseBottPump(isSAP, :);

    sapToUcctdMap = table();

    fig = figure('Name', 'SAP–UCCTD Depth Matching', ...
                 'Position', [100, 100, 1200, 800]);
    for s = 1:length(stations)
        stn = stations(s);
        sapRows    = sapTbl(sapTbl.Station_METAVAR_INDEXED_TEXT == stn, :);
        ucctdRows  = ucctdTbl(ucctdTbl.Station_METAVAR_INDEXED_TEXT == stn, :);

        if isempty(sapRows) || isempty(ucctdRows)
            continue;
        end

        ucctdDepths = ucctdRows.DEPTH_m_;
        ucctdAl = ucctdRows.Al_TP_CONC_BOTTLE_nmol_kg_;
        ucctdFe = ucctdRows.Fe_TP_CONC_BOTTLE_nmol_kg_;
        ucctdMn = ucctdRows.Mn_TP_CONC_BOTTLE_nmol_kg_;
        ucctdP  = ucctdRows.P_TP_CONC_BOTTLE_nmol_kg_;

        sapDepths = sapRows.DEPTH_m_;
        sapAl = max(sapRows.Al_SPT_CONC_PUMP_nmol_kg_, 0) + ...
                max(sapRows.Al_LPT_CONC_PUMP_nmol_kg_, 0);
        sapFe = max(sapRows.Fe_SPT_CONC_PUMP_nmol_kg_, 0) + ...
                max(sapRows.Fe_LPT_CONC_PUMP_nmol_kg_, 0);
        sapMn = max(sapRows.Mn_SPT_CONC_PUMP_nmol_kg_, 0) + ...
                max(sapRows.Mn_LPT_CONC_PUMP_nmol_kg_, 0);
        sapP = max(sapRows.P_SPT_CONC_PUMP_nmol_kg_, 0) + ...
               max(sapRows.P_LPT_CONC_PUMP_nmol_kg_, 0);
                
        for i = 1:height(sapRows)
            currentSAPDepth = sapDepths(i);
            
            % Improved zoom range (strict ±100 m, clamped to valid range)
            zBuffer = 100;
            zmin_raw = currentSAPDepth - zBuffer;
            zmax_raw = currentSAPDepth + zBuffer;
            fullMin = min([ucctdDepths; sapDepths]);
            fullMax = max([ucctdDepths; sapDepths]);
            zmin = max(zmin_raw, fullMin);
            zmax = min(zmax_raw, fullMax);

            % --- Row 1: Full profiles ---
            subplot(2,4,1); cla;
            plot(ucctdAl, ucctdDepths, 'b-o'); hold on;
            plot(sapAl, sapDepths, 'r-o');
            plot(sapAl(i), sapDepths(i), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            set(gca,'YDir','reverse'); title('Al - Full'); xlabel('nmol/kg'); ylabel('Depth (m)');
            
            subplot(2,4,2); cla;
            plot(ucctdFe, ucctdDepths, 'b-o'); hold on;
            plot(sapFe, sapDepths, 'r-o');
            plot(sapFe(i), sapDepths(i), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            set(gca,'YDir','reverse'); title('Fe - Full'); xlabel('nmol/kg');
            
            subplot(2,4,3); cla;
            plot(ucctdMn, ucctdDepths, 'b-o'); hold on;
            plot(sapMn, sapDepths, 'r-o');
            plot(sapMn(i), sapDepths(i), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            set(gca,'YDir','reverse'); title('Mn - Full'); xlabel('nmol/kg');
            
            subplot(2,4,4); cla;
            plot(ucctdP, ucctdDepths, 'b-o'); hold on;
            plot(sapP, sapDepths, 'r-o');
            plot(sapP(i), sapDepths(i), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            set(gca,'YDir','reverse'); title('P - Full'); xlabel('nmol/kg');
            
            % --- Row 2: Zoomed ---
            subplot(2,4,5); cla;
            plot(ucctdAl, ucctdDepths, 'b-o'); hold on;
            plot(sapAl, sapDepths, 'r-o');
            plot(sapAl(i), sapDepths(i), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            set(gca,'YDir','reverse'); ylim([zmin zmax]); title('Al - Zoomed'); xlabel('nmol/kg'); ylabel('Depth (m)');
            
            subplot(2,4,6); cla;
            plot(ucctdFe, ucctdDepths, 'b-o'); hold on;
            plot(sapFe, sapDepths, 'r-o');
            plot(sapFe(i), sapDepths(i), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            set(gca,'YDir','reverse'); ylim([zmin zmax]); title('Fe - Zoomed'); xlabel('nmol/kg');
            
            subplot(2,4,7); cla;
            plot(ucctdMn, ucctdDepths, 'b-o'); hold on;
            plot(sapMn, sapDepths, 'r-o');
            plot(sapMn(i), sapDepths(i), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            set(gca,'YDir','reverse'); ylim([zmin zmax]); title('Mn - Zoomed'); xlabel('nmol/kg');
            
            subplot(2,4,8); cla;
            plot(ucctdP, ucctdDepths, 'b-o'); hold on;
            plot(sapP, sapDepths, 'r-o');
            plot(sapP(i), sapDepths(i), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
            set(gca,'YDir','reverse'); ylim([zmin zmax]); title('P - Zoomed'); xlabel('nmol/kg');

            % --- Prompt ---
            fprintf('\n--- Station %s | SAP depth = %.1f m ---\n', stn, currentSAPDepth);
            fprintf('Choose UCCTD depth to pair:\n');
            for d = 1:length(ucctdDepths)
                fprintf('%2d: %.1f m\n', d, ucctdDepths(d));
            end
            fprintf(' 0: Skip\n');

            choice = input('Enter UCCTD depth index (0 to skip): ');

            if choice >= 1 && choice <= length(ucctdDepths)
                sapToUcctdMap = [sapToUcctdMap; ...
                    table(stn, currentSAPDepth, ucctdDepths(choice), ...
                    'VariableNames', {'Station', 'SAP_depth', 'UCCTD_depth'})];
            end
        end
    end
    close(gcf);  % Close figure after selection
end
