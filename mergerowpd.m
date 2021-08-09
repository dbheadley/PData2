%% mergerowpd
% Concatenates entries with the same group status

%% Syntax
%# newPData = mergerowpd(pData, selCols, grpCols)
%# newPData = mergerowpd(pData, selCols, grpCols, ..., 'FUNC', rowFunc)
%# newPData = mergerowpd(pData, selCols, grpCols, ..., 'MERGEFUNC', mergeFunc)
%# newPData = mergerowpd(pData, selCols, grpCols, ..., 'SKIPEMPTY')

%% Description
% Each row of pData that shares the same values in grpCols the selCols are
% concatenated into a single new pData entry.

% INPUT
% * pData - a pData cell array
% * selCols - columns to collapse
% * grpCols - columns to use when grouping columns that will be collapsed.
%   If it is empty, then all rows are merged

% OPTIONAL
% Arguments accepted by retcolpd can be passed
% 'FUNC' - a function handle, applied to each row of entries. The function
% should accept a cell array the same length as selCols, and return
% a cell array the same length as selCols. By default the function is
% @(x)x.
% 'SKIPEMPTY' - leaves out rows with empty entries.
% 'MERGEFUNC' - a function handle or cell array of function handles, 
% the function is applied to the merged entries, which are passed as a cell 
% array. When a single function is specified then the same function is used
% for all merged columns. When a cell array of function handles is used,
% the function in each cell is applied to the corresponding column. The
% cell array of functions must have the same number of cells as their are
% selCols specified.

% OUTPUT
% * newPData - a pData cell array, the pData cell array with the replaced
% collapsed entries.

%% Example

%% Executable code
function newPData = mergerowpd(pData, selCols, grpCols, varargin)

  % format inputs
  if ischar(selCols)
    selCols = {selCols};
  end

  if ischar(grpCols)
    grpCols = {grpCols};
  end

  sharedCols = intersect(selCols, grpCols);
  numShared = numel(sharedCols);
  if numShared > 0
    error('Some columns are shared by selCols and grpCols');
  end

  if any(strcmp('FUNC', varargin))
    rowFunc = varargin{find(strcmp('FUNC', varargin))+1};
    funcYes = true;
  else
    funcYes = false;
  end

  if any(strcmp('MERGEFUNC', varargin))
    mergeFunc = varargin{find(strcmp('MERGEFUNC', varargin))+1};
    if iscell(mergeFunc)
        if numel(mergeFunc)==1
            mergeFunc = repmat(mergeFunc,numel(selCols),1);
        elseif numel(mergeFunc) ~= numel(selCols)
            error('Number of mergeFuncs does not match selCols');
        end
    else
        mergeFunc = repmat({mergeFunc},numel(selCols),1);
    end
    mergeFuncYes = true;
  else
    mergeFuncYes = false;
  end
  
  allCols = [grpCols(:)' selCols(:)'];
  if any(strcmp('SKIPEMPTY', varargin))
    pData = retcolpd(pData, allCols, 'SKIPEMPTY');
  end
  
  newPData = makecolpd([], allCols, []);
  if isempty(grpCols)
    uniqRows = [];
    typeList = ones(size(pData,1)-1,1);
    numUniq = 1;
    newGrpColInds = [];
  else
    grpColInds = colindpd(pData, grpCols);
    [uniqRows, ~, typeList] = uniqueCellRows(pData(2:end,grpColInds));
    numUniq = size(uniqRows,1);
    newGrpColInds = colindpd(newPData, grpCols);
  end
  
  newSelColInds = colindpd(newPData, selCols);
  selColInds = colindpd(pData, selCols);
  numSelCols = length(selCols);
  newPData(2:(numUniq+1), newGrpColInds) = uniqRows;
  for j = 1:numUniq
    currInds = find(typeList' == j);
    
    if funcYes
      currVals = cell(1,numSelCols);
      for k = 1:length(currInds)
        currVals(k,:) = rowFunc(pData(currInds(k)+1,selColInds));
      end
    else
      currVals = pData(currInds+1,selColInds);
    end
    for k = 1:length(newSelColInds)
      newPData{j+1,newSelColInds(k)} = currVals(:, k);
      if mergeFuncYes
        newPData{j+1,newSelColInds(k)} = mergeFunc{k}(newPData{j+1,newSelColInds(k)});
      end
    end
  end