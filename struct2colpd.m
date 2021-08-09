%% table2colpd
% Creates columns using structures in a row
%% Syntax
%# [newPData newColNames] = struct2colpd(pData, selCols)

%% Description
% For each field contained in the structure of selCols a new column is created
% and its rows are filled with the corresponding values in that field. Each
% column is named after the field.

% INPUT
% * pData - a pData cell array
% * selCols - a cell array of strings or a string, the columns to have
% their structures converted columns. If multiple columns are specified,
% then each must have the same array size in their entries along the row,
% because they will be expanded in tandem.

% OPTIONAL

% OUTPUT
% * newPData - a pData cell array
%% Example

%% Executable code
function [newPData, newColNames] = struct2colpd(pData, selCols, varargin)

if ischar(selCols)
  selCols = {selCols};
end
  
selInds = colindpd(pData, selCols);
numSelInds = numel(selInds);
pdLength = numrowpd(pData);
newPData = pData;
newColNames = [];


if ~any(cellfun(@isstruct, pData(2:end,selInds)))
  error('Non-structure data types in selected columns');
end

for k = 1:numSelInds
  for j = 2:(pdLength+1)
    currEnt = pData{j, selInds(k)};
    if isempty(currEnt)
        continue;
    end
    fNames = fieldnames(currEnt);
    currColNames = cellfun(@(x)[selCols{k} '_' x], fNames, 'UniformOutput', false);
    newCols = cellfun(@(x)~any(strcmp(x,newColNames)), currColNames);
    if any(newCols)
      newPData = makecolpd(newPData, currColNames(newCols), repmat({{[]}},1,length(newCols)));
      newColNames = [newColNames; currColNames];
    end
    currColInds = colindpd(newPData, currColNames);
    
    for p = 1:length(fNames)
      newPData{j, currColInds(p)} = currEnt.(fNames{p});
    end
  end
end