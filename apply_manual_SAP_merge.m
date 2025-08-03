function mergedTbl = apply_manual_SAP_merge(CruiseBottPump, mapTable, dataStart, dataEnd, ucctdTag, sapTag)
%APPLY_MANUAL_SAP_MERGE Manually merges SAP data into UCCTD rows using a map.
%
%   mergedTbl = apply_manual_SAP_merge(CruiseBottPump, mapTable, dataStart, dataEnd, ucctdTag, sapTag)
%
%   Inputs:
%     - GP16bottpump : original table with both UCCTD and SAP data
%     - mapTable     : table with columns Station, SAP_depth, UCCTD_depth
%     - dataStart, dataEnd : column range with alternating data/quality vars
%     - ucctdTag, sapTag   : text labels for UCCTD and SAP samplers
%
%   Output:
%     - mergedTbl    : UCCTD-only table, with SAP data merged as specified

% Identify columns
vars = CruiseBottPump.Properties.VariableNames;
dataVars = vars(dataStart:2:dataEnd);
qualVars = vars(dataStart+1:2:dataEnd);

% Subset tables
isUCCTD = CruiseBottPump.SamplingDevice_INDEXED_TEXT == ucctdTag;
isSAP   = CruiseBottPump.SamplingDevice_INDEXED_TEXT == sapTag;

ucctdTbl = CruiseBottPump(isUCCTD, :);
sapTbl   = CruiseBottPump(isSAP, :);

mergedTbl = ucctdTbl;

% Loop through mapping
for i = 1:height(mapTable)
    stn = mapTable.Station(i);
    sapDepth = mapTable.SAP_depth(i);
    ucctdDepth = mapTable.UCCTD_depth(i);

    % Locate the SAP row
    sapRowIdx = find(sapTbl.Station_METAVAR_INDEXED_TEXT == stn & ...
        abs(sapTbl.DEPTH_m_ - sapDepth) < 0.01, 1);
    % Locate the UCCTD row
    ucctdRowIdx = find(mergedTbl.Station_METAVAR_INDEXED_TEXT == stn & ...
        abs(mergedTbl.DEPTH_m_ - ucctdDepth) < 0.01, 1);

    if isempty(sapRowIdx) || isempty(ucctdRowIdx)
        warning('Match not found for station %s at SAP %.1f → UCCTD %.1f', ...
            string(stn), sapDepth, ucctdDepth);
        continue;
    end

    % Merge if quality allows
    for k = 1:length(dataVars)
        sapQual = sapTbl.(qualVars{k})(sapRowIdx);
        if sapQual ~= 9
            % Merge value
            mergedTbl{ucctdRowIdx, dataVars{k}} = sapTbl{sapRowIdx, dataVars{k}};
            % Merge corresponding quality flag
            mergedTbl{ucctdRowIdx, qualVars{k}} = sapQual;
        end
    end
end

% Report
fprintf('Manually merged SAP data into %d UCCTD rows.\n', height(mapTable));
end
