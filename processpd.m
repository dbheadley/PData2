%% processpd
% Applies a function to entries in a pData cell array

%% Syntax
% newPData = processpd(pData, procCols, procfunc)
% newPData = processpd(pData, procCols, procfunc, ..., 'SKIPEMPTY')
% newPData = processpd(pData, procCols, procfunc, ..., 'SUFFIX', suffStr)
% newPData = processpd(pData, procCols, procfunc, ..., 'RESULTNAME', resName)
% newPData = processpd(pData, procCols, procfunc, ..., 'PLOT', plotFunc)
% newPData = processpd(pData, procCols, procfunc, ..., 'PARALLEL')
% newPData = processpd(pData, procCols, procfunc, ..., 'PAUSE')
% newPData = processpd(pData, procCols, procFunc, ..., 'PASSCELL')
% newPData = processpd(pData, procCols, procFunc, ..., 'SKIPEXISTING')
% newPData = processpd(pData, procCols, procFunc, ..., 'NOOUTPUT')
% newPData = processpd(pData, procCols, procFunc, ..., 'SAVE', saveParams)
% newPData = processpd(pData, procCols, procFunc, ..., 'LOAD', loadCols)
% newPData = processpd(pData, procCols, procFunc, ..., 'NOSTATUS')
% newPData = processpd(pData, procCols, procFunc, ..., 'DEBUG')

%% Description
% Applies a function, func, to the columns specified by procCols. The
% results are returned in a pData cell array with columns specified 

% INPUTS
% * pData - a pData cell array, the pData cell array to be processed
% * procCols - a cell array of strings, the columns to be fed into function. 
% If empty, then no columns are processed.
% * procFunc - a function handle, the function to be applied to the data.
% By default, all procCols are passed to the procFunc as arguments in the 
% order they are named.

% OPTIONAL
% * 'SKIPEMPTY' - rows with empty entries in procCols are skipped from
% analysis.
% * 'RESULTNAME' - a string or cell array of strings, specifies the names of the
% columns that processed results are returned to. Their should be as many
% column names as there are desired outputs from procFunc. If not specified,
% only the first output is saved. Overrides the 'SUFFIX' argument. The
% default output name is the concatenation of the procCols names and
% '_Result'.
% * 'SUFFIX' - a string or cell array of strings, the name of the columns 
% containing the processed results is the name of the processed column(s)
% with a suffix attached. When multiple outputs are desired, each should
% have its own suffix.
% * 'PARALLEL' - Uses parfeval from the parallel processing toolbox to speed up execution.
% * 'PLOT' - plotFunc is a handle to a plotting function. Plots the results
% as they are calculated.
% * 'PASSCELL' - passes the input to procFunc as a single cell array.
% * 'SKIPEXISTING' - if the row of the column where results are returned to
% is not empty, then the calculation is skipped. Useful when
% computationally intensive operations are performed on pData cell arrays
% that were recently collated with new entries.
% * 'PAUSE' - pause, waiting for user input, between each processing step.
% * 'SAVETEMP' - saveDir is a string, intermittently saves the new pData as
% a mat file into the directory specified by saveDir. 
% * 'NOOUTPUT' - function does not return an output, no new column is
% created.
% * 'LOAD' - loadCols is a boolean array the same size as procCols, with a
% true value denoting a column that should be treated as a file path to
% load (with a variable named 'result'), 
% * 'NOSTATUS' - suppresses the progress display output
% * 'DEBUG' - allows for errors to be passed to the command line or recruit
% the debugger.

% OUTPUTS
% * newPData - a pData cell array, results are returned as new columns. The
% default name is 'Results1', 'Results2', ... 'ResultsN'.

%% Example

%% Executable code
function newPData = processpd(pData, procCols, procFunc, varargin)


  if ischar(procCols)
    procCols = {procCols};
  end
  
  colInds = colindpd(pData, procCols);
  lenPData = numrowpd(pData);
  
  if any(strcmp('NOOUTPUT', varargin))
    noOut = true;
  else
    noOut = false;
  end
  
  if any(strcmp('DEBUG', varargin))
    yesDebug = true;
  else
    yesDebug = false;
  end
  
  if any(strcmp('NOSTATUS', varargin))
    noStatus = true;
  else
    noStatus = false;
  end
  
  if any(strcmp('RESULTNAME', varargin))
    colNameInd = find(strcmp('RESULTNAME', varargin))+1;
    newColNames = varargin{colNameInd};
    if ischar(newColNames)
      newColNames = {newColNames};
    end
  elseif any(strcmp('SUFFIX', varargin))
    suffInd = find(strcmp('SUFFIX', varargin))+1;
    suffixName = varargin{suffInd};
    newColNames = strjoin(procCols, '.');
    newColNames = cellfun(@(x)[newColNames x], suffixName, 'UniformOutput', false);
  else
      newColNames = strjoin([procCols {'Result'}],'_');
  end
  
  if any(strcmp('SKIPEMPTY', varargin))
    skipEmpty = true;
  else
    skipEmpty = false;
  end
  
  if any(strcmp('PLOT', varargin))
    pInd = find(strcmp('PLOT', varargin))+1;
    pFunc = varargin{pInd};
    figH = figure;
    plotYes = true;
  else
    plotYes = false;
  end
  
  if any(strcmp('PASSCELL', varargin))
    passCell = true;
  else
    passCell = false;
  end
  
  if any(strcmp('PARALLEL', varargin))
    try
      chunkSize = varargin{find(strcmp('PARALLEL', varargin))+1};
    catch
      chunkSize = 24;
    end
    if (~isnumeric(chunkSize) || (numel(chunkSize)~=1))
      error('Invalid chunk size specification');
    elseif isinf(chunkSize)
      chunkSize = numrowpd(pData)-1;
    end
    parYes = true;
    numCores = feature('numcores');
    currPool = parpool(numCores);
  else
    parYes = false;
  end
  
  if any(strcmp('PAUSE', varargin))
    pauseYes = true;
  else
    pauseYes = false;
  end
  
  if any(strcmp('SKIPEXISTING', varargin))
    skipExist = true;
  else
    skipExist = false;
  end
  
  if any(strcmp('SAVETEMP', varargin))
    saveDir = varargin{find(strcmp('SAVETEMP', varargin))+1};
    saveTempYes = true;
    savePts = unique(round(linspace(1,numrowpd(pData)+1,10)));
  else
    saveTempYes = false;
  end
  
  if ~noOut
    newPData = MakeCellTableCol(pData, newColNames);
    retColInds = colindpd(newPData, newColNames);
    numOutputs = length(retColInds);
  else
    newPData = pData;
    numOutputs = 0;
  end
  
  
  if ~noStatus
    waitFig = waitbar(0,['Progress on ' char(procFunc)]);
  end
  if parYes
    indList = 1:(chunkSize):(lenPData+1);
    if indList(end)~=(lenPData+1)
        indList(end+1) = (lenPData+1);
    end
    
      for p = 1:(length(indList)-1)
        currInds = (indList(p)+1):indList(p+1);
        if skipExist
          currInds(cellfun(@(x)~isempty(x), pData(currInds, retColInds))) = [];
          if isempty(currInds)
            continue;
          end
        end
        
        pDataChunk = pData(currInds,colInds);
        lenPDataChunk = size(pDataChunk,1);
        tempData = cell(lenPDataChunk,numOutputs);
        emptyEnt = [];
        if ~noStatus
            waitbar((p-1)/(length(indList)-1),waitFig,{['Progress on ' char(procFunc)] ...
                    [num2str(currInds(1)) ' ... ' num2str(currInds(end))]});
        end
        parfor k = 1:lenPDataChunk
          currData = pDataChunk(k,:);
          emptyEnt(k) = any(cellfun(@(x) isempty(x)&(~ischar(x)), currData));
          tempOut = cell(1,numOutputs);
          if ~(emptyEnt(k) && skipEmpty)
            if passCell
              [tempOut(:)] = procFunc(currData);
              tempData(k,:) = tempOut;
            elseif noOut
              procFunc(currData{:});
            else
              [tempOut{:}] = procFunc(currData{:});
              tempData(k,:) = tempOut;
            end
          end
          
        end
        if plotYes % will sometimes error out if all entries are empty
          for k = 1:lenPDataChunk
            if ~emptyEnt(k)
              subplot(ceil(sqrt(chunkSize)),ceil(sqrt(chunkSize)),k,'Parent',figH)
              pFunc(tempData(k,:));
              
            end
          end
          drawnow;
        end
        if pauseYes
            pause();
        end
        newPData(currInds,retColInds) = tempData;
        if saveTempYes
          if any(ismember(currInds, savePts))
            save([saveDir 'pdtemp.mat'], 'newPData');
          end
        end
      end
    delete(gcp('nocreate'));
  else
    
      for p = 2:(lenPData+1)
        if ~noStatus
          waitbar((p-1)/(lenPData+1),waitFig,{['Progress on ' char(procFunc)] ...
                    num2str(p-1)});
        end
        currData = pData(p,colInds);
        if skipExist
          if ~all(cellfun(@isempty,pData(p,retColInds)))
            continue;
          end
        end
        emptyEnt = cellfun(@(x) isempty(x)&(~ischar(x)), currData);
        if yesDebug
            if ~(any(emptyEnt) && skipEmpty)
                if passCell
                    [newPData{p,retColInds}] = procFunc(currData);
                elseif noOut
                    procFunc(currData{:});
                else
                    [newPData{p,retColInds}] = procFunc(currData{:});
                end
                if plotYes
                    figure(figH);
                    pFunc(newPData(p,retColInds));
                    drawnow;
                end
            end
        else
            try
                if ~(any(emptyEnt) && skipEmpty)
                  if passCell
                    [newPData{p,retColInds}] = procFunc(currData);
                  elseif noOut
                    procFunc(currData{:});
                  else
                    [newPData{p,retColInds}] = procFunc(currData{:});
                  end
                  if plotYes
                      figure(figH);
                      pFunc(newPData(p,retColInds));
                      drawnow;
                  end
                end
            catch ME
                warning(ME.message)
                continue;
            end
        end
        if pauseYes
            pause();
        end
        
        if saveTempYes
          if any(p == savePts)
            save([saveDir 'pdresult.mat'], 'newPData');
          end
        end
      end
  end
  
  if ~noStatus
    close(waitFig);
  end
    