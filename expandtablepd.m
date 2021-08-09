%% expandtablepd
% Adds columns and rows by expanding a table in a cell
%% Syntax
%# [newPData newColNames] = expandtablepd(pData, selCol)

%% Description
% For each row of selCol with a table, the table is 'broken-out' into the
% pData cell array with each variable in the table becoming a new column
% and each row in the table becoming a new row in pData. Empty rows are
% unprocessed. Deletes selCol.

% INPUT
% * pData - a pData cell array
% * selCols - a string or cell containing a string, a column whose entries
% are tables that will be expanded.

% OPTIONAL
% ROWNAME - a string, creates a column for row names in the table. The name
% of the column is specified by the rowName string.

% OUTPUT
% * newPData - a pData cell array
%% Example

%% Executable code
function [newPData, newColNames] = expandtablepd(pData, selCol, varargin)

if ischar(selCol)
  selCols = {selCol};
elseif numel(selCol) > 1
    error('Improper specification of selCol');
end

if any(strcmp(varargin, 'ROWNAME'))
    rowName = varargin{find(strcmp(varargin, 'ROWNAME'))+1};
    if isempty(rowName)
        rowName = 'RowNames';
    end
    rowNameYes = true;
else
    rowNameYes = false;
end

newPData = pData;


newPData = processpd(newPData, selCol, @(x)table2struct([x x.Properties.RowNames]), ...
        'RESULTNAME', selCol, 'SKIPEMPTY');
newPData = expandrowpd(newPData, selCol);
[newPData, newColNames] = struct2colpd(newPData, selCol);

if rowNameYes
    newPData = renamecolpd(newPData, newColNames{end}, [selCol{1} '_' rowName]);
    newColNames{end} = rowName;
end

newPData = deletecolpd(newPData, selCol);