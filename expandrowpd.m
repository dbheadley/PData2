%% expandrowpd
% Creates new rows for entries containg arrays

%% Syntax
%# newPData = expandrowpd(pData, selCols)
%# newPData = expandrowpd(pData, selCols, 'INDEXCOLS', colPrefixStr)
%# newPData = expandrowpd(pData, selCols, 'EXPANDFUNC', expandFunc)

%% Description
% For each entry in selCols, a new row is added for each value in the array
% in that entry. For instance, if the entry contains an array of 100
% integers, than 100 rows are created with each integer in a different one.

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
% 'EXPANDFUNC' - a function handle or cell array of function handles, 
% the function is applied to the expanded entries, which are passed as a cell 
% array. When a single function is specified then the same function is used
% for all expanded columns. When a cell array of function handles is used,
% the function in each cell is applied to the corresponding column. The
% cell array of functions must have the same number of cells as their are
% selCols specified.

% OUTPUT
% * newPData - a pData cell array
%% Example

%% Executable code
function newPData = expandrowpd(pData, selCols, varargin)

if ischar(selCols)
  selCols = {selCols};
end

if any(strcmp('EXPANDFUNC', varargin))
    expandFunc = varargin{find(strcmp('EXPANDFUNC', varargin))+1};
    if iscell(expandFunc)
        if numel(expandFunc)==1
            expandFunc = repmat(expandFunc,numel(selCols),1);
        elseif numel(expandFunc) ~= numel(selCols)
            error('Number of expandFuncs does not match selCols');
        end
    else
        expandFunc = repmat({expandFunc},numel(selCols),1);
    end
    expandFuncYes = true;
else
    expandFuncYes = false;
end


selInds = colindpd(pData, selCols);
pdLength = numrowpd(pData);
newPData = makecolpd([], pData(1,:), []);
if any(strcmp('INDEXCOLS', varargin))
  indexColYes = true;
  prefixStr = varargin{find(strcmp('INDEXCOLS', varargin))+1};
  dimNum = max(cellfun(@ndims,pData(2:end,selInds)));
  dimColNames = arrayfun(@(x)[prefixStr '_dim' num2str(x)], 1:dimNum, 'UniformOutput', false);
  newPData = makecolpd(newPData, dimColNames, {{[]}});
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
  if sizeEnts == 0
      newPData(end+1,newColInds) = pData(j,:);
      newPData(end,selInds) = currEnts;
      if indexColYes
          newPData(end,dimColInds) = repmat({0},1,dimNum);
      end
  else
      for k = 1:sizeEnts
          newPData(end+1,newColInds) = pData(j,:);
          newPData(end,selInds) = cellfun(@(x)x(k), currEnts, 'UniformOutput', false);
          if indexColYes
              [currSubs{1:dimNum}] = ind2sub(dimEnts{1}, k);
              newPData(end,dimColInds) = currSubs;
          end
          if expandFuncYes
              for i = 1:length(selInds)
                  newPData{end,selInds(i)} = expandFunc{i}(newPData{end,selInds(i)});
              end
          end
      end
  end
end