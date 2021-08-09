%% filterpd
% Filters a pdata cell array

%% Syntax
% newPData = filterpd(pData, fCols, matchArgs)
% newPData = filterpd(pData, fCols, matchArgs, 'INVERT')
% newPData = filterpd(pData, fCols, matchArgs, 'MODE', selMode)
% newPData = filterpd(pData, fCols, matchArgs, 'SKIPEMPTY')

%% Description
% Returns a new pData table with only those rows where their entries in
% each of the fCols matched the corresponding argument in matchArgs.

% INPUTS
% * pData - a pData cell array
% * fCols - an Nx1 cell array of strings, the columns that will be used to
% determine if a given row matches.
% * matchArgs - an Nx1 or 1x1 cell array, each cell corresponds to a 
% different match argument for the corresponding columns in fCols. If the
% cell contains a function handle, then the value in the entry is passed to
% that function, and a truth value is returned indicating whether that entry
% should be kept or not. Otherwise, the value is tested for equivalence
% with the value found in that cell. When only a single cell is present,
% then that argument is used for each of the fCols.

% OPTIONAL
% * 'INVERT' - instead of returning the selected entries they are excluded
% * 'MODE' - a string, selMode specifies the logical condition that must be 
% met across all the match arguments to allow an entry to be kept. 
%           'and' - all arguments must be true (default)
%           'or' - any argument can be true
% * 'SKIPEMPTY' - does not evaluate empty entries, they are kept in the
% table.

% OUTPUTS
% * newPData - a pData cell array

%% Example

%% Executable code
function newPData = filterpd(pData, fCols, matchArgs, varargin)
  
  % format input arguments
  if ischar(fCols)
    fCols = {fCols};
  end
  
  if ~iscell(matchArgs)
      error('matchArgs must be a cell');
  end
  
  if numel(matchArgs) == 1
      matchArgs = repmat(matchArgs, size(fCols));
  elseif numel(matchArgs) ~= numel(fCols)
      error('Unable to match arguments to columns');
  end
  
  fColInds = colindpd(pData, fCols);
  
  if any(strcmp('INVERT', varargin))
      invYes = true;
  else
      invYes = false;
  end
  
  if any(strcmp('MODE', varargin))
      selMode = varargin{find(strcmp('MODE', varargin))+1};
  else
      selMode = 'and';
  end
  
  if any(strcmp('SKIPEMPTY', varargin))
      filtRows = find(~any(cellfun(@isempty, pData(2:end,fColInds)),2))'+1;
  else
      filtRows = 2:size(pData,1);
  end
  
  for j = 1:numel(matchArgs)
      if ~isa(matchArgs{j}, 'function_handle')
          matchArgs{j} = @(x)isequaln(x, matchArgs{j});
      end
  end
  
  % filter data
  validEntries = true(size(pData));
  for j = 1:numel(matchArgs)
      for k = filtRows
        validEntries(k,fColInds(j)) = matchArgs{j}(pData{k,fColInds(j)});
      end
  end
  
  switch selMode
      case 'and'
          keepRows = all(validEntries(:,fColInds),2);
      case 'or'
          keepRows = any(validEntries(:,fColInds),2);
  end
  
  if invYes
      keepRows(2:end,:) = ~keepRows(2:end,:);
  end
  
  newPData = pData(keepRows, :);
  