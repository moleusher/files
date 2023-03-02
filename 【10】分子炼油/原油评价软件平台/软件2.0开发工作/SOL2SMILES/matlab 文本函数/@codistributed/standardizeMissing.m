function b = standardizeMissing(a, varargin)
%STANDARDIZEMISSING Insert standard missing data indicators into a codistributed table.
%   B = STANDARDIZEMISSING(A,INDICATORS)
%   B = STANDARDIZEMISSING(A,INDICATORS,'DataVariables',DATAVARS)
%   
%   See also STANDARDIZEMISSING, CODISTRIBUTED.
%   


%   Copyright 2016 The MathWorks, Inc.

% Must have two inputs and trailing inputs must come in pairs
narginchk(2,inf)
if mod(nargin,2) ~= 0
    error(message('MATLAB:standardizeMissing:NameValuePairs'));
end

if ~istable(a)
    error(message('parallel:array:UnsupportedFunction', upper(mfilename), classUnderlying(a)));
end

% If distributed in the second dimension, we need to take care over which
% variables to examine. For other dimensions this is just element-wise.
codistr = getCodistributor(a);
if codistr.Dimension == 2
    % We need to work out which columns are to be standardized and which of
    % those are on this worker. This helper will replace the DataVariables
    % input (if any) with local indices.
    try
        args = iGetDataVariables(a, varargin);
    catch err
        error(message('MATLAB:standardizeMissing:DataVariablesTableSubscript'));
    end
    
else
    args = varargin;
    
end

b = codistributed.pElementwiseUnaryOp(@standardizeMissing, a, args{:}); %#ok<DCUNK>

end

function args = iGetDataVariables(t,args)
% Determine which variables to operate on. We also strip DataVariables from
% the list of arguments.
idx = find( cellfun( @matchesDataVariables, args ), 1, 'last' );
if isempty(idx) || idx>=numel(args)
    % Not specified or no value. Leave args in place.
    return
end

selectedVars = args{idx+1};
tmpl = getTableTemplate(t);
allVars = tmpl.Properties.VariableNames;
[~,varIdxs] = distributedutil.lookupTableVars(selectedVars, allVars);

% Now work out which ones are on this worker
codistr = getCodistributor(t);
if labindex == 1
    first = 0;
else
    first = sum(codistr.Partition(1:labindex-1));
end
myVarIdxs = first + (1:codistr.Partition(labindex));
validIdxs = intersect(varIdxs, myVarIdxs);

% Subtract the previous worker variables to get the indices into the local
% part.
args{idx+1} = validIdxs - first;
end

function tf = matchesDataVariables(in)
% True if the input is a string that matches DataVariables (partial,
% case-insensitive)
if isempty(in) || ~(ischar(in) || (isstring(in) && isscalar(in)))
    tf = false;
    return;
end

tf = strncmpi(in,'DataVariables',min(13,length(in)));
end

