function newPData = filterbylistpd(pData, listPData, fCols, varargin)
    
    if any(strcmp(varargin,'INVERT'))
        invYes = true;
    else
        invYes = false;
    end
    
    listLen = numrowpd(listPData);
    listSelCols = colindpd(listPData,fCols);
    
    newPData = pData;
    
    for j = 2:(listLen+1)
        if invYes
            newPData = filterpd(newPData, fCols, listPData(j,listSelCols),'INVERT');
        end
    end
      