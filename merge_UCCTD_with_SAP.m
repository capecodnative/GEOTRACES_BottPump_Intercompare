function mergedTbl = merge_UCCTD_with_SAP(CruiseBottPump, dataStart, dataEnd, ucctdTag, sapTag)
%MERGE_UCCTD_WITH_SAP Merges SAP data into UCCTD rows from a sampling table.
%
%   mergedTbl = merge_UCCTD_with_SAP(GP16bottpump, dataStart, dataEnd, ucctdTag, sapTag)
%
%   - dataStart, dataEnd: index range of alternating value/quality columns.
%   - ucctdTag, sapTag: identifiers in SamplingDevice_INDEXED_TEXT (e.g., 'UCCTD', 'SAP').
%   - Merges SAP data into UCCTD rows from same station within ±20m depth.
%   - Only SAP values with quality ~= 9 are merged.
%   - Keeps only UCCTD rows in output.
%   - Prints merge summary.

    % Get variable names
    vars = CruiseBottPump.Properties.VariableNames;
    dataVars = vars(dataStart:2:dataEnd);
    qualVars = vars(dataStart+1:2:dataEnd);

    % Separate UCCTD and SAP rows
    isUCCTD = CruiseBottPump.SamplingDevice_INDEXED_TEXT == ucctdTag;
    isSAP = CruiseBottPump.SamplingDevice_INDEXED_TEXT == sapTag;

    ucctdTbl = CruiseBottPump(isUCCTD, :);
    sapTbl = CruiseBottPump(isSAP, :);
    usedSAP = false(height(sapTbl), 1);  % Track SAP usage

    % Preallocate merged table
    mergedTbl = ucctdTbl;
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
                    mergedTbl{i, dataVars{k}} = row.(dataVars{k});
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
end
