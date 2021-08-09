%% deletecolpd
% Deletes specified columns

%% Syntax
% newPData = deletecolpd(pData, dCols)

%% Description
% Removes the columns named in dCols that are in pData.

% INPUTS
% * pData - a pData cell array
% * dCols - an Nx1 cell array of strings, the columns that will be deleted

% OPTIONAL

% OUTPUTS
% * newPData - a pData cell array

%% Example

%% Executable code
function newPData = deletecolpd(pData, dCols)

    colInds = colindpd(pData, dCols);
    
    pData(:,colInds) = [];
    newPData = pData;