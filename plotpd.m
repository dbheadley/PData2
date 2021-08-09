%% plotpd
% Plots pData entries in grouped subplots
%% ADD 'LIST' TAG, FOLLOWED BY DIM ARG (R, C) PLOT DATA GROUPED BY THE SELECTED DIMENSION AS A LIST, I.E. NOT ORDERED 

%% Syntax
% pdH = plotpd(pData, dataCols, plotFunc)
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'ROWS', rowCols)
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'COLS', colCols)
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'FIGURES', figCols)
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'FULL')
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'EQUAXES')
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'EQUAXESFIGURE')
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'ALL')
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'PAUSE')
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'SAVE', saveDir)
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'PRINT')
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'PRINTDELETE')
% pdH = plotpd(pData, dataCols, plotFunc, ..., 'PAGESIZE', [left bottom width height])

%% Description
% Entries present in dataCols are passed to a plotting function, which
% plots them in the same axes. Using either the ROWS, COLS, or FIGURES
% options will tile the plots, grouping the entries in dataCols by their
% corresponding values in those columns specified by rowCols, colCols, or
% figCols. Columns used for tiling must contain either strings or scalars.

% INPUTS
% * pData - a pData cell array
% * dataCols - a cell array of strings, the entries to pass to the plotting
% function.
% * plotFunc - a function handle, produces the plots and should accept as 
% many inputs as there are columns in dataCols.

% OPTIONAL
% * ROWS - a cell array of strings, the columns used to group plots into
% rows.
% * COLS - a cell array of strings, the columns used to group plots into
% columns.
% * FIGURES - a cell array of strings, the columns used to group plots into
% figures.
% * FULL - every possible combination of grouping is used to layout plots. For
% combinations that lack a match in pData, a blank space is provided.
% * EQUAXES - all axes are plotted with the same size.
% * EQUAXESFIGURE - all axes are plotted with the same size for each figure.
% * ALL - passes all entries in a group as a cell array to the plot
% function. Each dataCol is given its own cell, and the entries for that
% column are passed as a cell array.
% * SQUARE - a cell array of strings, the columns used to group plots into
% a rectangular array of plots, not sorted along any particular dimension.
% Overrides ROWS and COLS.
% * PAUSE - pauses after each figure is rendered
% * SAVE - saves each figure to a selected directory. The filename is the
% figure name.
% * PRINT - prints each figure
% * PRINTDELETE - prints each figure, then deletes it.
% * PAGESIZE - Specifies the size of the figure on the printed page in inches.

% OUTPUTS
% * pdH - a pData cell array ordered by the values in groupCols of the 
% handles for each of the axes

%% Example

%% Executable code
function pdH = plotpd(pData, dataCols, plotFunc, varargin)

  if ischar(dataCols)
    dataCols = {dataCols};
  end

  if any(strcmp('EQUAXES', varargin));
    equAxesYes= true;
  else
    equAxesYes = false;
  end

  if any(strcmp('EQUAXESFIGURE', varargin));
    equAxesFigYes= true;
  else
    equAxesFigYes = false;
  end
  
  if any(strcmp('PRINT', varargin));
    printYes= true;
  else
    printYes = false;
  end
  
  if any(strcmp('PAGESIZE', varargin));
    pageSize = varargin{find(strcmp(varargin,'PAGESIZE'))+1};
  else
    pageSize = [0 0 11 8];
  end
  
  
  if any(strcmp('PRINTDELETE', varargin));
    printDeleteYes= true;
  else
    printDeleteYes = false;
  end
  
  if any(strcmp('FULL', varargin));
    fullYes= true;
  else
    fullYes = false;
  end
  
  if any(strcmp('ALL', varargin));
    allYes= true;
  else
    allYes = false;
  end
  
  if any(strcmp('PAUSE', varargin));
    pauseYes= true;
  else
    pauseYes = false;
  end
  
  if any(strcmp('SAVE', varargin))
    saveDir = varargin{find(strcmp('SAVE', varargin))+1};
    saveYes = true;
  else
    saveYes = false;
  end
  
  if any(strcmp('SQUARE', varargin))
    sqCols = varargin{find(strcmp('SQUARE', varargin))+1};
    tileSqYes = true;
  else
    sqCols = [];
    tileSqYes = false;
  end
    
  if any(strcmp('ROWS', varargin)) && ~tileSqYes
    rowCols = varargin{find(strcmp('ROWS', varargin))+1};
    if ischar(rowCols)
      rowCols = {rowCols};
    end
    tileRowYes = true;
  else
    rowCols = [];
    tileRowYes = false;
  end

  if any(strcmp('COLS', varargin)) && ~tileSqYes
    colCols = varargin{find(strcmp('COLS', varargin))+1};
    if ischar(colCols)
      colCols = {colCols};
    end
    tileColYes = true;
  else
    colCols = [];
    tileColYes = false;
  end

  
  if any(strcmp('FIGURES', varargin))
    figCols = varargin{find(strcmp('FIGURES', varargin))+1};
    if ischar(figCols)
      figCols = {figCols};
    end
    tileFigYes = true;
  else
    figCols = [];
    tileFigYes = false;
  end

  if any(strcmp('SKIPEMPTY', varargin))
    pData = retcolpd(pData, [rowCols(:); colCols(:); sqCols(:); figCols(:); dataCols(:)], 'SKIPEMPTY');
  else
    pData = retcolpd(pData, [rowCols(:); colCols(:); sqCols(:); figCols(:); dataCols(:)]);
  end
 dataColInds = colindpd(pData, dataCols);
  
  if tileFigYes
    figColInds = colindpd(pData, figCols);
    for j = 1:length(figColInds)
      currCol = figColInds(j);
      if ~(all(cellfun(@isscalar,pData(2:end,currCol))) || iscellstr(pData(2:end,currCol))) 
        error(['Group column ' figCols{j} ' is not scalar or string']);
      end
    end
    pdH = uniquerowpd(retcolpd(pData, figCols), figCols);
  else
    pdH = [];
  end
  pdH = makecolpd(pdH, {'Figure Handle' 'Axes Handle'}, {{[]} {[]}});
  figHInd = colindpd(pdH, 'Figure Handle');
  axesHInd = colindpd(pdH, 'Axes Handle');
  if tileFigYes
    figColInds = colindpd(pdH, figCols);
  end
  
  if tileRowYes
    rowColInds = colindpd(pData, rowCols);
    for j = 1:length(rowColInds)
      currCol = rowColInds(j);
      if ~(all(cellfun(@isscalar,pData(2:end,currCol))) || iscellstr(pData(2:end,currCol))) 
        error(['Group column ' rowCols{j} ' is not scalar or string']);
      end
    end
    if fullYes
      rowVals = uniquerowpd(retcolpd(pData, rowCols), rowCols);
    end
  end
  
  if tileColYes
    colColInds = colindpd(pData, colCols);
    for j = 1:length(colColInds)
      currCol = colColInds(j);
      if ~(all(cellfun(@isscalar,pData(2:end,currCol))) || iscellstr(pData(2:end,currCol))) 
        error(['Group column ' colCols{j} ' is not scalar or string']);
      end
    end
    if fullYes
      colVals = uniquerowpd(retcolpd(pData, colCols), colCols);
    end
  end
  
  if tileSqYes
    sqColInds = colindpd(pData, sqCols);
    for j = 1:length(sqColInds)
      currCol = sqColInds(j);
      if ~(all(cellfun(@isscalar,pData(2:end,currCol))) || iscellstr(pData(2:end,currCol))) 
        error(['Group column ' sqCols{j} ' is not scalar or string']);
      end
    end
    if fullYes
      sqVals = uniquerowpd(retcolpd(pData, sqCols), sqCols);
    end
  end
  
  for j = 2:size(pdH,1)
    if tileFigYes
      matchVals = pdH(j,figColInds);
      figTitleParts = cellfun(@(x)num2str(x), matchVals, 'UniformOutput', false);
      figTitle = strjoin(figTitleParts);
      currData = filterpd(pData, figCols, matchVals);
    else
      figTitle = '';
      currData = pData;
    end
    
    pdH{j, figHInd} = figure();
    set(gcf,'Name', figTitle);
    set(gcf,'Units', 'inches');
    set(gcf, 'PaperPosition', pageSize);
    set(gcf, 'PaperOrientation', 'landscape');
    annotation('textbox',[0 .95 .1 .02], 'String', figTitle, 'LineStyle', 'none');
    if tileRowYes
      if ~fullYes
        rowVals = uniquerowpd(retcolpd(currData, rowCols), rowCols);
      end
      rowCount = numrowpd(rowVals);
      clear rowNames;
      for k = 2:(rowCount+1)
        rowNames{k-1} = strjoin(cellfun(@(x)num2str(x), rowVals(k,:), 'UniformOutput', false));
      end
    else
      rowCount = 1;
      rowNames{1} = '';
    end
  
    if tileColYes
      if ~fullYes
        colVals = uniquerowpd(retcolpd(currData, colCols), colCols);
      end
      colCount = numrowpd(colVals);
      clear colNames;
      for k = 2:(colCount+1)
        colNames{k-1} = strjoin(cellfun(@(x)num2str(x), colVals(k,:), 'UniformOutput', false));
      end
    else
      colCount = 1;
      colNames{1} = '';
    end
    
    if tileSqYes
      if ~fullYes
        sqVals = uniquerowpd(retcolpd(currData, sqCols), sqCols);
      end
      sqCount = numrowpd(sqVals);
      clear sqNames;
      for k = 2:(sqCount+1)
        sqNames{k-1} = strjoin(cellfun(@(x)num2str(x), sqVals(k,:), 'UniformOutput', false));
      end
      rowCount = ceil(sqrt(sqCount));
      colCount = ceil(sqrt(sqCount));
%       fList = factor(sqCount);
%       rowCount = prod(fList(1:floor(end/2)));
%       colCount = prod(fList((floor(end/2)+1):end));
    end
    
    
    axesCounter = 1;
    axesHList = [];
    for r = 1:rowCount
      for c = 1:colCount 
        if tileRowYes && tileColYes
          plotData = filterpd(currData, [rowCols(:); colCols(:)], ...
            [rowVals(r+1,:) colVals(c+1,:)]);
          titleStr = [rowNames{r} ' and ' colNames{c}];
        elseif tileRowYes
          plotData = filterpd(currData, rowCols, rowVals(r+1,:));
          titleStr = rowNames{r};
        elseif tileColYes
          plotData = filterpd(currData, colCols, colVals(c+1,:));
          titleStr = colNames{c};
        elseif tileSqYes
          if ((r-1)*colCount)+c > sqCount
            break;
          end
          plotData = filterpd(currData, sqCols(:), sqVals(((r-1)*colCount)+c+1,:));
          titleStr = sqNames{((r-1)*colCount)+c};
        else
          plotData = currData;
          titleStr = figTitle;
        end
        
        if size(plotData,1) == 1
          continue;
        end
        
        if tileRowYes || tileColYes || tileSqYes
          axesHList(axesCounter) = subplot(rowCount, colCount, ((r-1)*colCount)+c);
        else
          axesHList(axesCounter) = axes();
        end
        pause(0.1);
        hold on;
        plotDataColInds = colindpd(plotData, dataCols);
        if allYes
          inp = cell(1,length(plotDataColInds));
          for p = 1:length(plotDataColInds)
            inp{p} = plotData(2:end,plotDataColInds(p));
          end
          plotFunc(inp{:});
        else
          for p = 2:size(plotData,1)
            plotFunc(plotData{p,plotDataColInds});
          end
        end
        title(titleStr, 'FontSize', 8);
        drawnow();
        axis tight;
        axesCounter = axesCounter + 1;
      end
    end
    pdH{j, axesHInd} = axesHList;
%     tightfig();
    if equAxesFigYes
        xlims = cell2mat(arrayfun(@(x)xlim(x),axesHList,'UniformOutput',false)');
        ylims = cell2mat(arrayfun(@(x)ylim(x),axesHList,'UniformOutput',false)');
        zlims = cell2mat(arrayfun(@(x)zlim(x),axesHList,'UniformOutput',false)');
        newXLim= [min(xlims(:,1)) max(xlims(:,2))];
        newYLim = [min(ylims(:,1)) max(ylims(:,2))];
        newZLim = [min(zlims(:,1)) max(zlims(:,2))];
        for p = 1:length(axesHList)
            axes(axesHList(p));
            xlim(newXLim);
            ylim(newYLim);
            zlim(newZLim);
        end
    end
    
    if saveYes
      saveas(pdH{j,figHInd},strcat(saveDir,figTitle,'.eps'),'epsc');
      close(pdH{j,figHInd});
      pdH{j,figHInd} = nan;
    end
    if printDeleteYes
        print;
        close(pdH{j,figHInd});
    end
    
    if pauseYes
      pause;
    end
  end
  
  figH = retcolpd(pdH, 'Figure Handle', 'NOHEADER');
  pdH = expandrowpd(pdH, {'Axes Handle'});
  
  if equAxesYes && ~printDeleteYes
    % A SPLIT/APPLY/COMBINE TYPE FUNCTION SHOULD BE ABLE TO DO THIS IN ONE
    % LINE, TRY THIS IN THE FUTURE...
    pdH = processpd(pdH, {'Axes Handle'}, @(x)get(x, 'xlim'), 'RESULTNAME', 'xlim');
    pdH = processpd(pdH, {'Axes Handle'}, @(x)get(x, 'ylim'), 'RESULTNAME', 'ylim');
    pdH = processpd(pdH, {'Axes Handle'}, @(x)get(x, 'zlim'), 'RESULTNAME', 'zlim');
%     lims = mergerowpd(pdH, {'xlim' 'ylim' 'zlim'}, [], 'SKIPEMPTY');
    lims = retcolpd(pdH, {'xlim' 'ylim' 'zlim'}, 'SKIPEMPTY', 'NOHEADER', 'RETMAT', 1);
    newXLim = [min(lims(:,1)) max(lims(:,2))];
    newYLim = [min(lims(:,3)) max(lims(:,4))];
    newZLim = [min(lims(:,5)) max(lims(:,6))];
    axesList = retcolpd(pdH, {'Axes Handle'}, 'NOHEADER', 'SKIPEMPTY', 'RETMAT', 1);
    for j = axesList(:)'
      set(j, 'xlim', newXLim);
      set(j, 'ylim', newYLim);
      set(j, 'zlim', newZLim);
    end
  end
    
  if printYes && ~printDeleteYes
      for j = 1:length(figH)
        figure(figH{j});
        print;
      end
  end