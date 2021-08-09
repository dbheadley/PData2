%% renamecolpd
% Renames specified columns

%% Syntax
% newPData = renamecolpd(pData, rCols, newColNames)

%% Description
% Renames the columns named in rCols that are in pData.

% INPUTS
% * pData - a pData cell array
% * rCols - an Nx1 cell array of strings, the columns that will be deleted
% * newColNames - an Nx1 cell array of strings, the new column names

% OPTIONAL

% OUTPUTS
% * newPData - a pData cell array

%% Example

%% Executable code
function newPData = renamecolpd(pData, rCols, newColNames)
    
    if ischar(newColNames)
      newColNames = {newColNames};
    end
    
    if ischar(rCols)
      rCols = {rCols};
    end
    
    if numel(newColNames) ~= numel(rCols)
      error('Unequal number of column names provided');
    end
    
    colInds = colindpd(pData, rCols);
    
    pData(1,colInds) = newColNames;
    newPData = pData;