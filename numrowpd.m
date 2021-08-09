%% numrowpd
% Returns the number of entries in pData
%% Syntax
%# numEnt = numrowpd(pData)

%% Description
% Determines the number of entries in pData, which is essentially the
% number of rows minus 1.

% INPUT
% * pData - a pData cell array

% OUTPUT
% * numEnt - an integer, the number of entries in pData

%% Example

%% Executable code
function numEnt = numrowpd(pData)
  numEnt = size(pData,1)-1;