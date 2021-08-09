%% uniquerowpd
% Retains only the rows of pData with unique sets of entries

%% Syntax
% newPData = uniquerowpd(pData, idCols)
% newPData = uniquerowpd(pData, idCols, ..., 'SKIPEMPTY')

%% Description
% Compares the values in the entries for idCols between rows and keeps the
% first instance of each unique one.

% INPUTS
% * pData - a pData cell array
% * idCols - an Nx1 cell array of strings, the columns that will be used to
% evaluate uniqueness.

% OPTIONAL
% * 'SKIPEMPTY' - does not evaluate empty entries
% * 'REMOVECOLS' - eliminate columns not specified by idCols

% OUTPUTS
% * newPData - a pData cell array

%% Example

%% Executable code
function newPData = uniquerowpd(pData, idCols, varargin)
  if ischar(idCols)
    idCols = {idCols};
  end
  
  if any(strcmp('SKIPEMPTY', varargin))
    skipEmpty = true;
  else
    skipEmpty = false;
  end
  
  if any(strcmp('REMOVECOLS', varargin))
     pData = deletecolpd(pData, setdiff(pData(1,:), idCols));
  end
  
  idColInds = colindpd(pData, idCols);
  if skipEmpty
      emptyRow = any(cellfun(@(x)isempty(x)&(~ischar(x)), pData(2:end,idColInds)),2);
      pData = pData([true; ~emptyRow], :);
  end
  
  
  
  waitFig = waitbar(0,'Finding unique rows: trying fast approach');
  fastWorked = true;
  for j = 1:length(idColInds)
      currCol = idColInds(j);
      try
          if iscellstr(pData(2:end,currCol))
            [~,~,uniqInds(:,currCol)] = unique(pData(2:end,currCol));
          else
            matTemp = cell2mat(pData(2:end,currCol));
            if size(matTemp,1)~=numrowpd(pData)
                error('Failed using fast approach');
            else
                [~,~,uniqInds(:,currCol)] = unique(matTemp,'rows');
            end
          end
      catch
          fastWorked = false;
          break;
      end
      waitbar(j/length(idColInds),waitFig,'Finding unique rows: trying fast approach');
  end
  
  if fastWorked
      waitbar(1,waitFig,'Finding unique rows: fast approach worked');
      [~,uniqInds] = unique(uniqInds,'rows');
      newPData = pData([1; uniqInds+1],:);
  else
      waitbar(0,waitFig,'Finding unique rows: slow approach');
      newPData = cell(size(pData));
      newPData([1 2],:) = pData([1 2],:);
      newPDCount = 3;
      for j = 2:size(pData,1)
          waitbar(j/size(pData,1),waitFig,'Finding unique rows: slow approach');
          
          currRow(1,:) = pData(j,idColInds);
          for k = (newPDCount-1):-1:2
              if isequaln(newPData(k,idColInds), currRow)
                  break;
              elseif k == 2%size(newPData,1)
                  newPData(newPDCount,:) = pData(j,:);
                  newPDCount = newPDCount + 1;
              end
          end
      end
      newPData(newPDCount:end,:) = [];
  end
  close(waitFig);