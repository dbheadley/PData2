%% table2pd
% Creates a pData cell array from a table 

%% Syntax
%# newPData = table2pd(tblData)


%% Description
% A pData cell array is created using the entries, variable names, and
% column names in tblData.

% INPUT
% * tblData - a table

% OPTIONAL

% OUTPUT
% * newPData - a pData cell array
%% Example

%% Executable code
function newPData = table2pd(tblData)
    newPData = [tblData.Properties.VariableNames; table2cell(tblData)];
    
    
    