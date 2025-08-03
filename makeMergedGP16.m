% Identify columns
dataStart = 34;
dataEnd  = 1187;
vars = GP16bottpump.Properties.VariableNames;
dataVars = vars(dataStart:2:dataEnd);
qualVars = vars(dataStart+1:2:dataEnd);

% Separate UCCTD and SAP rows
isUCCTD = GP16bottpump.SamplingDevice_INDEXED_TEXT == 'UCCTD';
isSAP = GP16bottpump.SamplingDevice_INDEXED_TEXT == 'SAP';

ucctdTbl = GP16bottpump(isUCCTD, :);
sapTbl = GP16bottpump(isSAP, :);
usedSAP = false(height(sapTbl), 1);  % Track SAP usage

% Preallocate merged table
GP16merge = ucctdTbl;
mergeCount = 0;
noSAPMatchCount = 0;

for i = 1:height(ucctdTbl)
    stn = ucctdTbl.Station_METAVAR_INDEXED_TEXT(i);
    depth = ucctdTbl.DEPTH_m_(i);

    % Find SAP matches within ±20m and same station
    matchIdx = find(sapTbl.Station_METAVAR_INDEXED_TEXT == stn & ...
                    abs(sapTbl.DEPTH_m_ - depth) <= 20);

    if isempty(matchIdx)
        noSAPMatchCount = noSAPMatchCount + 1;
        continue;
    end

    % Try to find first match with valid quality data
    mergedThisRow = false;
    for j = 1:length(matchIdx)
        rowIdx = matchIdx(j);
        row = sapTbl(rowIdx, :);

        hasValidData = false;
        for k = 1:length(dataVars)
            if row.(qualVars{k}) ~= 9
                GP16merge{i, dataVars{k}} = row.(dataVars{k});
                hasValidData = true;
            end
        end

        if hasValidData
            mergeCount = mergeCount + 1;
            usedSAP(rowIdx) = true;
            mergedThisRow = true;
            break;
        end
    end

    if ~mergedThisRow
        noSAPMatchCount = noSAPMatchCount + 1;
    end
end

% Report
fprintf('%d UCCTD rows merged with SAP data.\n', mergeCount);
fprintf('%d UCCTD rows had no usable SAP match.\n', noSAPMatchCount);
fprintf('%d SAP rows were not used in any merge.\n', sum(~usedSAP));

% Cleanup
clear dataStart vars dataVars qualVars dataEnd mergeCount noSAPMatchCount
clear isUCCTD isSAP ucctdTbl sapTbl usedSAP
clear i j k stn depth matchIdx row rowIdx hasValidData mergedThisRow