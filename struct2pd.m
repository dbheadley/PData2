%% struct2pd
% Creates a pData cell array from a structure

%% Syntax
%# newPData = struct2pd(structData)
%# newPData = struct2pd(structData, 'SELFIELDS', selFields)


%% Description
% A structure array is converted to a pData cell array. Each field of the
% structure is a different column, and each entry in the structure array is
% a different row.

% INPUT
% * structData - a structure

% OPTIONAL
% 'SELFIELDS' - selFields is a string or cell array of strings, the names
% of the fields to be included in newPData.

% OUTPUT
% * newPData - a pData cell array
%% Example

%% Executable code
function newPData = struct2pd(structData, varargin)

    if any(strcmp('SELFIELDS', varargin))
        selFields = varargin{find(strcmp('SELFIELDS', varargin))+1};
        if ischar(selFields)
          selFields = {selFields};
        end
    else
        selFields = fieldnames(structData);
    end
    
    newPData = [];
    
    numFields = numel(selFields);
    numRows = numel(structData);
    for j = 1:numFields
      currField = selFields{j};
      newPData = makecolpd(newPData, currField, []);
      currColInd = colindpd(newPData, currField);
      newPData(2:(numRows+1), currColInd) = {structData.(currField)};
    end