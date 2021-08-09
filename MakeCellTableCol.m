function [data varargout] = MakeCellTableCol(data, varargin)
    if length(varargin)==1
        if iscell(varargin{1})
            selCols = varargin{1};
        else
            selCols = varargin(1);
        end
    else
        selCols = varargin;
    end
    
    for j = 1:length(selCols)
        newColName = selCols{j};
        if ~isempty(data)
            newColInd = find(strcmp(data(1,:), newColName));
        else
            newColInd = [];
        end
        if isempty(newColInd)
            data{1, end+1} = newColName;
            newColInd = size(data,2);
        end
        varargout{j} = newColInd;
    end
    
    if (nargout == 2) && (length(varargout) > 1)
        varargout{1} = [varargout{:}];
    end