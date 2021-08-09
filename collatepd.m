%% collatepd
% Matches entries in pData cell arrays
%% ADD OPTION FOR 'NONMATCHING' TAG ON SPECIFIED INDCOLS, THAT IS IT WILL MATCH THOSE ROWS WHERE
%% THEIR VALUES IN THAT COLUMN DO NOT MATCH! PERHAPS ALSO A BOOLEAN OPERATOR OPTION AS WELL, 
%% SINCE MATCHING IS WITH CURRENTLY JUST 'AND'
%% Syntax
% newPData = collatepd(pDataInd, pDataSamp, indCols, sampCols)
% newPData = collatepd(pDataInd, pDataSamp, indCols, sampCols, ..., 'ENUMERATE')
% newPData = collatepd(pDataInd, pDataSamp, indCols, sampCols, ..., 'RENAMECOLS', newSampNames)
% newPData = collatepd(pDataInd, pDataSamp, indCols, sampCols, ..., 'EXPAND')
% newPData = collatepd(pDataInd, pDataSamp, indCols, sampCols, ..., 'SKIPEMPTY')
% newPData = collatepd(pDataInd, pDataSamp, indCols, sampCols, ..., 'CULL')

%% Description
% Matches rows in pDataInd with those in pDataSamp based on the entries in
% columns indCols, and maps the value in sampCols from pdDataSamp into 
% pDataInd. If the entries in indCols repeat, then the first match is
% sampled. When multiple pDataSamp arrays are provided, the sample is taken
% from the last pDataSamp array that matched. 

% INPUTS
% * pDataInd - a pData cell array, the pData cell array that the sampled
% data will be written to.
% * pDataSamp - a pData cell array, or a cell array of pData cell arrays, 
% the pData cell array that provides the sampled data.
% * indCols - a cell array of strings, columns to be used to index between
% the pData cell arrays.
% * sampCols - a cell array of string, the entries to be sampled. If empty,
% then all columns that are not indCols are sampled.

% OPTIONAL
% * 'ENUMERATE' - instead of just taking the first match for indCol repeats,
% a new row is added to newPData for each repeated match.
% * 'SKIPEMPTY' - rows with empty entries in indCols are skipped from
% collation. They remain in the table but nothing is collated to them.
% * 'EXPAND' - if a row in pDataSamp is not matched with pDataInd, either
% because its index columns do not match those in pDataInd or they do match
% but are the after the first occurence then it is appended to the end of newPData.
% * 'RENAMECOLS' - a cell array of strings, renames the columns of sampCols
% returned by newPData.
% * 'CULL' - if a row in pDataInd does not have a match in pDataSamp, then
% it is removed.
% * 'MULTIPLESAMPLES' - indicates that pDataSamp is an array of pData cell
% arrays, and repeats the collatepd function for each one.

% OUTPUTS
% * newPData - a pData cell array

%% Example

%% Executable code
function newPData = collatepd(pDataInd, pDataSamp, indCols, sampCols, varargin)


  if any(strcmp('MULTIPLESAMPLES', varargin))
    pDataSampMult = pDataSamp;
  else
    pDataSampMult = {pDataSamp};
  end

  if ischar(sampCols)
    sampCols = {sampCols};
  end

  if isempty(sampCols)
    noSampCols = true;
  else
    noSampCols = false;
  end
  
  if ischar(indCols)
    indCols = {indCols};
  end

  if any(strcmp('RENAMECOLS', varargin))
    newSampNames = varargin{find(strcmp('RENAMECOLS', varargin))+1};
    if ischar(newSampNames)
      newSampNames = {newSampNames};
    end
    if numel(newSampNames) ~= numel(sampCols)
      error('New sample column names does not match sample columns');
    end
  else
    newSampNames = sampCols;
  end
  
  if any(strcmp('ENUMERATE', varargin))
    enumYes = true;
  else
    enumYes = false;
  end

  if any(strcmp('EXPAND', varargin))
    expandYes = true;
  else
    expandYes = false;
  end

  if any(strcmp('CULL', varargin))
    cullYes = true;
  else
    cullYes = false;
  end
  
  
  waitFig = waitbar(0,'Collating');

  newPData = pDataInd;
  for n = 1:numel(pDataSampMult)
    pDataSamp = pDataSampMult{n};  
    pDataInd = newPData;
    if noSampCols
      sampCols = pDataSamp(1,:);
      sampCols = setdiff(sampCols, indCols);
      newSampNames = sampCols;
    end
    
    newPData = makecolpd(newPData, newSampNames(~ismember(newSampNames, ...
      pDataInd(1,:))),{{[]}});
    indColIndInds = colindpd(pDataInd, indCols);
    indColSampInds = colindpd(pDataSamp, indCols);
    indColNewInds = colindpd(newPData, indCols);
    sampColNewInds = colindpd(newPData, newSampNames);
    sampColSampInds = colindpd(pDataSamp, sampCols);
    
    if any(strcmp('SKIPEMPTY', varargin))
      indRowsInd = find(~any(cellfun(@isempty, pDataInd(2:end,indColIndInds)),2))'+1;
      indRowsSamp = find(~any(cellfun(@isempty, pDataSamp(2:end,indColSampInds)),2))'+1;
    else
      indRowsInd = 2:size(pDataInd,1);
      indRowsSamp = 2:size(pDataSamp,1);
    end

    unMatchedSamp = true(size(pDataSamp,1),1);
    unMatchedSamp(setxor(2:size(pDataSamp,1), indRowsSamp)) = false;
    unMatchedSamp(1) = false;

    unMatchedInd = [];

    for j = indRowsInd
      waitbar(j/indRowsInd(end),waitFig,['Collating sample: ' num2str(n)]);
      currMatch = pDataInd(j,indColIndInds);
      priorMatch = false;
      for k = indRowsSamp
        if isequaln(currMatch, pDataSamp(k, indColSampInds))
          unMatchedSamp(k) = false;
          if ~enumYes
            newPData(j, sampColNewInds) = pDataSamp(k, sampColSampInds);
            priorMatch = true;
            break;
          else
            if ~priorMatch
              newPData(j, sampColNewInds) = pDataSamp(k, sampColSampInds);
            else
              newPData(end+1, :) = newPData(j,:);
              newPData(end, sampColNewInds) = pDataSamp(k, sampColSampInds);
            end
            priorMatch = true;
          end
        end
      end
      if ~priorMatch
        unMatchedInd(end+1) = j;
      end
    end

    if expandYes
      numUnMatch = sum(unMatchedSamp);
      newPData((end+1):(end+numUnMatch), [indColNewInds sampColNewInds]) = ...
        pDataSamp(unMatchedSamp, [indColSampInds sampColSampInds]);
    end

    if cullYes
      newPData(unMatchedInd,:) = [];
    end
  end
  
  close(waitFig);