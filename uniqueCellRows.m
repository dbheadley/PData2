%% uniqueCellRows
% Works like unique with the 'rows' tag
%% Syntax
%# [uniq, m, n] = uniqueCellRows(cellArr)

%% Description
% Returns the unique rows in a cell array.

% INPUT
% * cellArr - a cell array, the cell array that will be evaluated for
% unique rows

% OUTPUT
% * uniq - a cell array, each row is a unique row from cellArr
% * m - an integer vector, the indices for the first occurrence of each 
% unique row. uniq = cellArr(m,:)
% * n - an integer vector, for each row in cellArr the corresponding index
% in uniq. cellArr = uniq(n,:)

%% Example

%% Executable code
function [uniq, m, n] = uniqueCellRows(cellArr, varargin)

  numRows = size(cellArr, 1);
  uniq = cellArr(1,:);
  m = 1;
  n = [1; nan(numRows-1,1)];

  for j = 1:numRows
    yesUniq = true;
    numUniq = size(uniq,1);
    for k = numUniq:-1:1
      if isequaln(cellArr(j,:), uniq(k,:))
        n(j) = k;
        yesUniq = false;
        break
      end
    end
    if yesUniq
      uniq(numUniq+1,:) = cellArr(j,:);
      m = [m j];
      n(j) = numUniq+1;
    end
  end
      