%% pd2table
% Creates a table from a pData cell array 

%% Syntax
%# newTable = pd2table(pData)


%% Description
% A table is created using the column names and entries in pData.

% INPUT
% * pData - a pData cell array

% OPTIONAL
% * 'ROWNAMECOL' - a string, the name of a column that provides
% variable names. Entries must be unique.

% OUTPUT
% * newTable - a table
%% Example

%% Executable code
function newTable = pd2table(pData, varargin)
    
    if any(strcmp('ROWNAMECOL', varargin))
        rowColName = varargin{find(strcmp('ROWNAMECOL', varargin))+1};
        rowColInd = colindpd(pData, rowColName);
        rowList = pData(2:end, rowColInd);
        pData = deletecolpd(pData, rowColName);
        rowColYes = true;
    else
        rowColYes = false;
    end
    
    oldColNames = pData(1,:);
    for j = 1:length(oldColNames)
        newColNames{j} = pData{1,j};
        badChar = regexp(newColNames{j}, '[\W\s]');
        if ~isempty(badChar)
            newColNames{j}(badChar) = '_';
            if any(strcmp(newColNames{j}, oldColNames))
                error(['Name conflict for ' newColNames{j}]);
            end
        end
    end
    
    if rowColYes
        newTable = cell2table(pData(2:end,:), 'RowNames', rowList, ...
            'VariableNames', newColNames);
    else
        newTable = cell2table(pData(2:end,:), 'VariableNames', newColNames);
    end