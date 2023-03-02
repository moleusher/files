function dt = table(varargin)
%TABLE Build a codistributed table from codistributed arrays
%   DT = TABLE(D1,D2,...) creates a codistributed table DT from codistributed
%   arrays D1, D2, ... . All arrays must be codistributed and have the same
%   number of rows. The result is always distributed using a 1D distribution
%   scheme over the first dimension.
%    
%   DT = TABLE(..., 'VariableNames', {'name1', ..., 'name_M'}) creates a table
%   that has the specified variable names.  The names need not be valid MATLAB
%   identifiers, but must be unique.
%    
%   See also TABLE, CODISTRIBUTED.
%   


%   Copyright 2016 The MathWorks, Inc.

% Attempt to deal with trailing p-v pairs.
if nargin > 2 && ischar(varargin{end-1})
    flag = varargin{end-1};
    if ~isequal(flag, 'VariableNames')
        error(message('MATLAB:bigdata:array:InvalidTableFlag'));
    end
    if ~(iscellstr(varargin{end}) && numel(varargin{end}) == nargin - 2)
        error(message('MATLAB:bigdata:array:TableVariableNamesFormat', nargin - 2));
    end
    varNames = varargin{end};
    if numel(unique(varNames)) ~= numel(varNames)
        error(message('MATLAB:bigdata:array:TableVariableNamesUnique'));
    end
    varValues = varargin(1:end-2);
else
    varNames = cell(1, nargin);
    for idx = 1:nargin
        ipName = inputname(idx);
        if isempty(ipName)
            ipName = sprintf('Var%d', idx);
        end

        % Check for collision with preceding names
        ipBase  = ipName;
        nextIdx = 1;
        while ismember(ipName, varNames(1:idx-1))
            % Need to uniquify
            ipName  = sprintf('%s_%d', ipBase, nextIdx);
            nextIdx = nextIdx + 1;
        end
        varNames{idx} = ipName;
    end
    varValues = varargin;
    assert(numel(unique(varNames)) == numel(varNames));
end

% Data inputs must all be codistributed
if ~all(cellfun(@iscodistributed, varValues))
    error(message('parallel:distributed:AllTableArgsDistributed'));
end

% Data inputs must all have same number of rows
nVars = numel(varNames);
nRows = cellfun(@(x) size(x,1), varValues);
if ~all(nRows == nRows(1))
    error(message('MATLAB:table:UnequalVarLengths'));
end
nRows = nRows(1);

% We require the inputs to be distributed in dimension 1. We want even
% distribution of data, so use the number of rows to design the ideal
% distribution.
varValues = cellfun(@(x) iRedistribute(x, nRows), varValues, 'UniformOutput', false);
localParts = cellfun(@(x) getLocalPart(x), varValues, 'UniformOutput', false);

% Now form the table on each worker
localTable = table(localParts{:}, 'VariableNames', varNames);

% Build a new codistributed from the local parts
codistr = codistributor1d(1, codistributor1d.unsetPartition, [nRows,nVars]);
dt = codistributed.pDoBuildFromLocalPart(localTable, codistr);

end

function out = iRedistribute(in, nRows)
% Redistribute one input
sz = size(in);
sz(1) = nRows;
codistr = codistributor1d(1, codistributor1d.unsetPartition, sz);
out = redistribute(in, codistr);
end
