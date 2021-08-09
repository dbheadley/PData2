%%%%% INCOMPLETE INCOMPLETE DO NOT USE %%%%%%%%%%%%%%%%%%%%%
%% expandArraypd
% Creates new rows or columns along a particular dimension for entries containg arrays

%% Syntax
%# newPData = expandArraypd(pData, selCols, selDim, expType)
%# newPData = expandArraypd(pData, selCols, selDim, expType, 'INDEXCOLS', colPrefixStr)

%% Description
% For each entry in selCols, a new row or column is added for each set of 
% values in the array that share a given index along selDim in that entry. 
% For instance, if the entry contains a 5x100 array integers, and selDim is
% 1, and expType is 'COL', then 5 new columns are created, each with 1x100
% arrays.

% INPUT
% * pData - a pData cell array
% * selCols - a cell array of strings or a string, the columns to have
% their entries converted to new rows. If multiple columns are specified,
% then each must have the same array size in their entries along the row,
% because they will be expanded in tandem.



% OPTIONAL
% * 'INDEXCOLS' - colPrefixStr is a string, creates columns specifying the
% indices of the values. For N-dimensional arrays, N columns are created, 
% one for the index of each dimension. Each column name is colPrefixStr
% followed by '_dimX', where X is 1 to N.

% OUTPUT
% * newPData - a pData cell array
%% Example

%% Executable code
function newPData = expandrowpd(pData, selCols, varargin)

if ischar(selCols)
  selCols = {selCols};
end

selInds = colindpd(pData, selCols);
pdLength = numrowpd(pData);
newPData = makecolpd([], pData(1,:), []);
if any(strcmp('INDEXCOLS', varargin))
  indexColYes = true;
  prefixStr = varargin{find(strcmp('INDEXCOLS', varargin))+1};
  dimColNames = arrayfun(@(x)[prefixStr '_dim' num2str(x)], 1:dimNum, 'UniformOutput', false);
  newPData = makecolpd(newPData, dimColNames, []);
  dimColInds = colindpd(newPData, dimColNames);
else
  indexColYes = false;
end

newColInds = colindpd(newPData, pData(1,:)); 
newPData(2,:) = [];

for j = 2:(pdLength+1)
  currEnts = pData(j, selInds);
  dimEnts = cellfun(@size, currEnts, 'UniformOutput', false);
  sameTest = all(cellfun(@(x)isequal(x, dimEnts{1}), dimEnts));
  if ~sameTest
    error(['Unmatched array size at row ' num2str(j)]);
  end
  sizeEnts = prod(dimEnts{1});
  for k = 1:sizeEnts
    newPData(end+1,newColInds) = pData(j,:);
    newPData(end,selInds) = cellfun(@(x)x(k), currEnts, 'UniformOutput', false);
    if indexColYes
      [currSubs{1:dimNum}] = ind2sub(dimEnts{1}, k);
      newPData(end,dimColInds) = currSubs;
    end
  end
end