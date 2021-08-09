%% unpivotpd
% Unpivots a pdata cell array
% OPTIONS NOT FULLY IMPLEMENTED!!!!!!!!!!!!!!!!!!!!

%% Syntax
% [newPData newColNames] = unpivotpd(pData, typeCols)
% [newPData newColNames] = unpivotpd(pData, typeCols, 'DELIMITER', delimStr)
% [newPData newColNames] = unpivotpd(pData, typeCols, 'COLNAMES', colNames)
% [newPData newColNames] = unpivotpd(pData, typeCols, 'SKIPEMPTY')

%% Description
% Column names in typeCols are converted to a new data column. If a
% delimiter is specified then the string following the delimiter is
% returned as the entries in the categorical columns.

% INPUTS
% * pData - a pData cell array
% * typeCols - a cell array of strings, columns to be used to columnize the
% entries in dataCol.

% OPTIONAL
% * delimStr - a regular expression string, which delimits the portion of 
% the column name to  extract and return as values in the new categorical 
% columns. Must be a valid regular expression for returning a token. If
% multiple tokens are returned then an error is thrown.
% * colNames - a 2 element cell array of strings, the first entry is the
% name of the results column, while the second is the name of the type
% column.
% * 'SKIPEMPTY' - does not write out empty entries

% OUTPUTS
% * newPData - a pData cell array
% * newColNames - a 2 element cell array of strings, the names of the new categorical
% and data columns. 
%% Example

%% Executable code
function [newPData, newColNames] = unpivotpd(pData, typeCols, varargin)
  if ischar(typeCols)
    typeCols = {typeCols};
  end
  colInds = colindpd(pData, typeCols);
  
  if any(strcmp('DELIMITER', varargin))
      delimStr = varargin{find(strcmp('DELIMITER', varargin))+1};
      typeNames = regexp(typeCols, delimStr, 'tokens');
      if any(cellfun(@numel, typeNames)~=1)
        error('String delimiter does not return valid tokens');
      end
      typeNames = cellfun(@(x)x{1},typeNames, 'UniformOutput', false);
  else
      typeNames = typeCols;
  end
  
  if any(strcmp('COLNAMES', varargin))
      colNames = varargin{find(strcmp('COLNAMES', varargin))+1};
  else
      colNames = {'Result' 'Type'};
  end
  
  if any(strcmp('SKIPEMPTY', varargin));
      pData = filterpd(pData, typeCols, repmat({@(x)~(isempty(x)&(~ischar(x)))},1,numel(typeCols)));
  end
  
  
  numTypeCols = length(colInds);
  numEnt = numrowpd(pData);
  numCol = size(pData,2);
  newPData = pData(1,:);
  newPDInd = 2;
  for j = 2:(numEnt+1)
      for k = 1:numTypeCols
        newPData(newPDInd,1:numCol) = pData(j,:);
        newPData{newPDInd,numCol+1} = typeNames{k};
        newPData{newPDInd,numCol+2} = pData{j,colInds(k)};
        newPDInd = newPDInd + 1;
      end
  end
  newPData{1,numCol+1} = colNames{2};
  newPData{1,numCol+2} = colNames{1};
  newColNames = colNames;
  newPData = deletecolpd(newPData, typeCols);