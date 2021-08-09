%% colindpd
% Returns the indices for named columns
%% Syntax
%# colInds = colindpd(pData, retCols)

%% Description
% For internal use by pd functions, returns the indices of the columns
% named by retCols.

% INPUT
% * pData - a pData cell array
% * retCols - a string or cell array of strings, the names of the columns
% to be returned. If retCols is an empty vector, then all columns are
% returned, but if retCols is a cell array with an empty cell, then an
% error is thrown.

% OPTIONAL

% OUTPUT
% * colInds - A vector of integers, the indices of the columns 

%% Example

%% Executable code
function colInds = colindpd(pData, retCols, varargin)
  
  if ischar(retCols)
      retCols = {retCols};
  elseif isempty(retCols)
      colInds = 1:size(pData,2);
      return;
  end
  
  for j = 1:numel(retCols)
    colInds{j} = find(strcmp(retCols{j}, pData(1,:)));
    if isempty(colInds{j})
        error(['Column "' retCols{j} '" not found.']);
    elseif length(colInds{j})>1
        error(['Column "' retCols{j} ' " is redundant.']);
    end
  end
  colInds = cell2mat(colInds);
  
%   if length(unique(colInds))~=length(retCols)
%       error('Nonunique column inds');
%   end