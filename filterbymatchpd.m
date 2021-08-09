%% filterbymatchpd
% Filters a pData array based on shared entries in another pData array
%% Syntax
%# newPData = filterbymatchpd(pData, matchPData, fCols)
%# newPData = filterbymatchpd(pData, matchPData, fCols, 'INVERT')

%% Description
% Returns the rows in pData whose fCols match those in matchPData's
% fCols.

% INPUT
% * pData - a pData cell array to be filtered
% * matchPData - a pData cell array that supplies that matches
% * fCols - a cell array of strings, the names of the columns used for
% matching

% OPTIONAL
% * INVERT - returns those entries that did not match instead

% OUTPUT
% * newPData - a pData cell array containing the matched entries

%% Example

%% Executable code
function newPData = filterbymatchpd(pData, matchPData, fCols, varargin)
    
    if any(strcmp(varargin,'INVERT'))
        invYes = true;
    else
        invYes = false;
    end
    
    uniqName = false;
    while ~uniqName
        tempColName = char(randperm(255,10));
        uniqName = ~any(strcmp(tempColName,colnamepd(matchPData)));
    end
    matchPData = makecolpd(matchPData,tempColName,{{true}});
    
    newPData = collatepd(pData, matchPData, fCols, tempColName);
    
    if invYes
        newPData = filterpd(newPData, tempColName, {@(x)isempty(x)});
    else
        newPData = filterpd(newPData, tempColName, {true});
    end
    
    newPData = deletecolpd(newPData, tempColName);