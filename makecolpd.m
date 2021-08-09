function pData = makecolpd(pData, names, entries)

  % names are new column names
  % entries, a cell array of values to place in the new columns. There
  % should be as many cells as there are new columns. Inside each
  % cell, the values to fill all the rows with is specified. If a single
  % value is given, then all rows and columns get the same value. 

  if ischar(names)
    names = {names};
  end

  if ~iscell(entries) && ~isempty(entries)
    error('Entries must be specified as a cell array or empty ([])');
  end

  if isempty(entries)
    entries = {[]};
  end

  if (length(entries) ~= length(names)) && (length(entries) ~= 1)
    error('Unmatched names and entries');
  elseif length(entries) == 1
    entries = repmat(entries, size(names));
  end
  
  if isempty(pData)
    pData = [names; entries];
    return;
  end

  numEnt = numrowpd(pData);
  colNames = pData(1,:);

  
  for j = 1:length(names)
    currName = names{j};
    currEntries = entries{j};
    if numel(currEntries) == numEnt
      currEnts = currEntries;
      if ~iscell(currEnts)
        currEnts = num2cell(currEnts);
      end
    elseif (numel(currEntries) == 1) || isempty(currEntries)
      currEnts = repmat(entries{j}, [numEnt, 1]);
    else
      error('Entries do not match size of pData');
    end
    
    nameMatch = find(strcmp(currName, colNames));
    if isempty(nameMatch)
      pData{1,end+1} = currName;
      pData(2:end, end) = currEnts;
    else
      pData(2:end,nameMatch) = currEnts;
    end
  end