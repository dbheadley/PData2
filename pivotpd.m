%% pivotpd
% Pivots a pdata cell array
%% Syntax
% [newPData newColNames] = pivotpd(pData, typeCols, dataCols, indCols)
% [newPData newColNames] = pivotpd(pData, typeCols, dataCols, indCols, ..., 'SKIPEMPTY')
% [newPData newColNames] = pivotpd(pData, typeCols, dataCols, indCols, ..., 'COUNT')
% [newPData newColNames] = pivotpd(pData, typeCols, dataCols, indCols, ..., 'FUNC', opFunc)

%% Description
% Entries present in 'dataCols' are sorted into different columns based on
% the corresponding values found in 'typeCols'. These columns are collected
% into a new pData array and index with 'indCols'.

% INPUTS
% * pData - a pData cell array
% * typeCols - a cell array of strings, columns to be used to columnize the
% entries in dataCol. Columns must contain either scalars or strings.
% * dataCols - a cell array of strings, the entries to columnize.
% * indCols - a cell array of strings, the columns that will index the
% entries in 'dataCol' during the collation. Function should accept a row
% vector cell array as input.

% OPTIONAL
% * FUNC - a function handle, to be applied to the grouped data, by
% default it returns the row-wise concatenated grouped data
% * SKIPEMPTY - makes opFunc only process non-empty groups
% * COUNT - counts number of entries that met a particular criterion, same
% as specifying an opFunc @(x)numel(x)

% OUTPUTS
% * newPData - a pData cell array
% * newColNames - a cell array of strings, the names of the new data
% columns

%% Example

%% Executable code
function newPData = pivotpd(pData, typeCols, dataCols, indCols, varargin)
  
  if ischar(typeCols)
    typeCols = {typeCols};
  end
  
  if ischar(dataCols)
    dataCols = {dataCols};
  end
  
  if ischar(indCols)
    indCols = {indCols};
  end
  
  if any(strcmp('FUNC', varargin))
      opFunc = varargin{find(strcmp('FUNC', varargin))+1};
  else
      opFunc = @(x)x;
  end
  
  if any(strcmp('COUNT', varargin))
     opFunc = @(x)numel(x);
  end
  
  if any(strcmp('SKIPEMPTY', varargin));
      skipEmptyYes = true;
      pData = retcolpd(pData, [typeCols(:); dataCols(:); indCols(:)], 'SKIPEMPTY');
  else
    skipEmptyYes = false;
  end
  
  
  
  
  colInds = colindpd(pData, typeCols);
  [uniq, ~, n] = uniqueCellRows(pData(2:end, colInds));
  uniqStrs = cellfun(@(x)num2str(x), uniq, 'UniformOutput', false);
  numUniqCols = size(uniq,1);
  
  for j = 1:numUniqCols
    selInds = [1; find(n==j)+1];
    nameAppend = ['_' strjoin(uniqStrs(j,:), '_')];
    newColNames{j} = strcat(dataCols,{nameAppend});
    if ischar(newColNames{j})
        newColNames{j} = {newColNames{j}};
    end
    subPData{j} = retcolpd(pData(selInds,:), [indCols(:); dataCols(:)]');
    subPData{j} = renamecolpd(subPData{j}, dataCols, newColNames{j});
    subPData{j} = mergerowpd(subPData{j}, newColNames{j}, indCols);
  end
  
  newColNames = [newColNames{:}];
  if numel(subPData) ~= 1
    newPData = collatepd(subPData{1}, subPData(2:end), indCols, [], 'MULTIPLESAMPLES', 'EXPAND');
  end
  
  for j = 1:length(newColNames)
      currCol = newColNames{j};
      
      if skipEmptyYes
          newPData = processpd(newPData, currCol, opFunc, 'RESULTNAME', currCol, 'SKIPEMPTY');
      else
          newPData = processpd(newPData, currCol, opFunc, 'RESULTNAME', currCol);
      end
  end
    
  