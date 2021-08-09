%% retcolpd
% Returns the entries from selected pData columns
%% Syntax
%# retData = retcolpd(pData, retCols)
%# retData = retcolpd(pData, retCols, ..., 'NOHEADER')
%# retData = retcolpd(pData, retCols, ..., 'SKIPNAN')
%# retData = retcolpd(pData, retCols, ..., 'SKIPFAIL')
%# retData = retcolpd(pData, retCols, ..., 'SKIPEMPTY')
%# retData = retcolpd(pData, retCols, ..., 'SINGLECOL')
%# retData = retcolpd(pData, retCols, ..., 'RETMAT', projDim)
%# retData = retcolpd(pData, retCols, ..., 'RETFUNC', retFunc)
%# retData = retcolpd(pData, retCols, ..., 'FILLEMPTY', fillVal)

%% Description
% Retrieves the selected columns in 'retCols'. If the 'NoHeader'
% instruction is passed then the header of the columns is removed.

% INPUT
% * pData - a pData cell array
% * retCols - a string or cell array of strings, the names of the columns
% to be returned. If retCols is empty, then all cloumns are returned.

% OPTIONAL
% * 'NOHEADER' - Columns are returned without the header label
% * 'SKIPEMPTY' - If an entry in one of the selected columns is empty, then
% skip that entire row
% * 'SKIPNAN' - If an entry in one of the selected columns is a single nan,
% then skip that entire row
% * 'SKIPFAIL' - If 'retFunc' errors out on one of the selected columns,
% then skip that entire row
% * 'RETFUNC' - The immediately following function handle will be applied
% to each returned entry
% * 'RETMAT' - Attempts to convert retData to a matrix. The projDim
% argument that follows determines the dimension along which results are
% projected.
% * 'SINGLECOL' - Returns data as a single column, equivalent to retData(:)
% * 'FILLEMPTY' - a matlab data type, fills each empty entry with the
% variable specified by 'fillVal'. Overrides SKIPEMPTY.

% OUTPUT
% * retData - a pData cell array or regular cell array ('NoHeader') 

%% Example

%% Executable code
function retData = retcolpd(pData, retCols, varargin)
    
  if ischar(retCols)
      retCols = {retCols};
  end
  
  if sum(strcmp('NOHEADER', varargin))
    noHeader = true;
  else
    noHeader = false;
  end
  
  if sum(strcmp('SKIPNAN', varargin))
    skipNan = true;
  else
    skipNan = false;
  end
  
  if sum(strcmp('SKIPEMPTY', varargin))
    skipEmpty = true;
  else
    skipEmpty = false;
  end
  
  if sum(strcmp('SKIPFAIL', varargin))
    skipFail = true;
  else
    skipFail = false;
  end
  
  if sum(strcmp('SINGLECOL', varargin))
    singleCol = true;
  else
    singleCol = false;
  end
  
  if any(strcmp('RETFUNC', varargin))
    retFunc = varargin{find(strcmp('RETFUNC', varargin))+1};
  else
    retFunc = @(x)x;
  end
  
  if any(strcmp('RETMAT', varargin))
    retMat = true;
    projDim = varargin{find(strcmp('RETMAT', varargin))+1};
  else
    retMat = false;
  end
  
  if any(strcmp('FILLEMPTY', varargin))
    fillVal = varargin{find(strcmp('FILLEMPTY', varargin))+1};
    for j = 1:numel(retCols)
        currCol = retCols{j};
        pData = processpd(pData, currCol, @(x)ifelsefunc(isempty(x), fillVal, x), ...
            'RESULTNAME', currCol);
    end
  end
  
  
  
  colInds = colindpd(pData, retCols);
  
  retData = pData(:,colInds);
  
  if skipEmpty
    emptyInds = cellfun(@(x) isempty(x)&(~ischar(x)), retData(2:end,:));
    emptyRows = [false; any(emptyInds,2)];
    retData(emptyRows, :) = [];
  end
  
  if skipNan
    nanInds = cellfun(@(x) isequaln(x, nan(1,1)), retData(2:end,:));
    nanRows = [false; any(nanInds,2)];
    retData(nanRows, :) = [];
  end
  
  if skipFail
    failRows = false(size(retData,1),1);
    for j = 2:size(retData,1)
      try cellfun(retFunc, retData(j,:), 'UniformOutput', false)
        failRows(j) = false;
      catch
        disp(['RetFunc failed on row ' num2str(j)]);
        failRows(j) = true;
      end
    end
    retData(failRows,:) = [];
  end
  
  for j = 2:size(retData,1)
    for k = 1:size(retData,2)
      retData{j,k} = retFunc(retData{j,k});
    end
  end
  
  if noHeader
    retData = retData(2:end,:);
  end
  
  if singleCol
    retData = retData(:);
  end
  
  if retMat
    if projDim ~= 1
      permDims = 1:projDim;
      permDims(projDim) = 1;
      permDims(1) = projDim;
    else
      permDims = [1 2];
    end
    retData = permute(retData, permDims);
    retData = cell2mat(retData);
  end