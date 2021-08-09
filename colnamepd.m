%% colnamepd
% Returns the names of the columns
%% Syntax
%# colNames = colnamepd(pData)

%% Description
% For internal use by pd functions, returns the names of the columns in
% pData

% INPUT
% * pData - a pData cell array

% OPTIONAL

% OUTPUT
% * colInds - A vector of integers, the indices of the columns 

%% Example

%% Executable code
function colNames = colnamepd(pData, varargin)
  colNames = pData(1,:);