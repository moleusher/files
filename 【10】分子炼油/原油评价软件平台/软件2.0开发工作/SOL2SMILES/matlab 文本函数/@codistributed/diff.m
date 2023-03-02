function X = diff(X, n, dim)
%DIFF Difference and approximate derivative.
%   Y = DIFF(X)
%   Y = DIFF(X,N)
%   Y = DIFF(X,N,DIM)
%   
%   Example:
%   spmd
%       N = 10;
%       X = codistributed.colon(1,N).^2;
%       Y = diff(X)
%   end
%   
%   returns codistributed.colon(3,2,19).
%   
%   See also DIFF, CODISTRIBUTED, CODISTRIBUTED/SUM,CODISTRIBUTED/PROD 


%   Copyright 2006-2014 The MathWorks, Inc.

if nargin < 2 || isempty(n)
    n = 1;
else
    n = distributedutil.CodistParser.gatherIfCodistributed(n);
    if ~isscalar(n) || ~isPositiveIntegerValuedNumeric(n)
        error(message('MATLAB:diff:differenceOrderMustBePositiveInteger'));
    end
end

if nargin < 3
    isDefaultDim = true;
else
    dim = distributedutil.CodistParser.gatherIfCodistributed(dim);
    if ~isscalar(dim) || ~isPositiveIntegerValuedNumeric(dim)
        error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
    end
    isDefaultDim = false;
end

try
    if ~isa(X, 'codistributed')
        if isDefaultDim
            X = diff(X, n);
        else
            X = diff(X, n, dim);
        end
    else
        X = iCheckClassUnderlying(X);
        if isDefaultDim
            X = iDiffDefaultDim(X, n);
        else
            X = iDiffSpecifiedDim(X, n, dim);
        end
    end
catch E
    throw(E);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iCheckClassUnderlying - check X is a valid class for DIFF, and cast
% to double if necessary
function X = iCheckClassUnderlying(X)
if islogical(X) || isaUnderlying(X, 'char')
    X = double(X);
elseif isnumeric(X)
    if isinteger(X) && ~isreal(X)
        error(message('MATLAB:diff:complexIntegersNotSupported'));
    end
else
    error(message('MATLAB:diff:unsupportedClass', classUnderlying(X)));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X = diff(X, n)
function X = iDiffDefaultDim(X, n)
if iCheckDefaultDimEmpty(X, n)
    X = iProcessDefaultDimEmptyCases(X, n);
else
    % Indicate that the dimension must be derived :
    dim = [];
    if n == 1
        X = iProcessNonEmptyInputWithUnitDiffOrder(X, dim);
    else
        X = iProcessNonEmptyInput(X, n, dim);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X = diff(X, n, dim)
function X = iDiffSpecifiedDim(X, n, dim)

if issparse(X) && dim > 2
    error(message('MATLAB:spAttrib:workDimNot1or2'));
end

if iCheckSpecifyDimEmpty(X, n, dim)
    X = iProcessSpecifyDimEmptyCases(X, n, dim);
else
    if n == 1
        X = iProcessNonEmptyInputWithUnitDiffOrder(X, dim);
    else
        X = iProcessNonEmptyInput(X, n, dim);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the minimum number of diff operations that generates the
% empty matrix. For example, if X has dims {4, 5, 3},
% then maxOrder = (4-1)+(5-1)+(3-1)+1 = 10, which means diff(X, 10)
% will be an empty 0-0 matrix while diff(X,9) is not empty.
% If dims = {4, 5, 0} then maxOrder is defined as (4-1)+(5-1)+1 = 8,
% which is the number of diff to generate a 1-1-0 matrix, diff(X, k)
% when k>=8 will all generate a 1-1-0 matrix
% If dims = {0, 4, 5}, the maxOrder is define as 1 which will
% generate an empty matrix with the same dims {0, 4, 5}
function n = iGetDefaultMaxDiffOrder(X)
szX = size(X);
firstZeroDim = find(szX == 0, 1, 'first');
if ~isempty(firstZeroDim)
    szX = szX(1:(firstZeroDim - 1));
end
n = 1 + sum(szX-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if the result is going to be an empty matrix
% For diff(X,n)
function tf = iCheckDefaultDimEmpty(X, n)
maxDiffOrder = iGetDefaultMaxDiffOrder(X);
tf = (isempty(X) || n >= maxDiffOrder);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if the result is going to be an empty matrix
% For diff(X,N,Dim)
function tf = iCheckSpecifyDimEmpty(X, n, dim)
nDims  = ndims(X);
inDims = size(X);
tf     = (isempty(X) || (dim > nDims) || inDims(dim) <= n);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build an empty result of the correct class.
function X = iBuildEmpty(dims, X)
X = zeros(dims, 'like', X);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process diff(X,N) case and the result is an empty matrix
function X = iProcessDefaultDimEmptyCases(X, n)
maxDiffOrder = iGetDefaultMaxDiffOrder(X);
if n >= maxDiffOrder && ~isempty(X)
    X = iBuildEmpty([0 0], X);
else
    % X must be empty. Calculate the output size by subtracting up to n from the
    % leading dimensions, stopping if we get to a zero in the dimension vector.
    inDims     = size(X);
    outDims    = inDims;
    nRemaining = n;
    stopDim    = find(inDims == 0, 1, 'first') - 1;

    for i = 1:stopDim
        numToSubtract = min(nRemaining, outDims(i) - 1);
        outDims(i)    = outDims(i) - numToSubtract;
        nRemaining    = nRemaining - numToSubtract;
    end
    X = iBuildEmpty(outDims, X);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process diff(X,N,Dim) case and the result is an empty matrix
function X = iProcessSpecifyDimEmptyCases(X, n, dim)
nDimsIn  = ndims(X);
inDims   = size(X);
nDimsOut = max(dim, nDimsIn);
% append ones to outDims to ensure correct dimensionality
outDims  = [inDims, ones(1, max(0, nDimsOut - nDimsIn))];
if dim > nDimsIn || inDims(dim) <= n
    outDims(dim) = 0;
else
    outDims(dim) = outDims(dim) - n;
end
X = iBuildEmpty(outDims, X);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process diff(X), diff(X,1) and diff(X,1,Dim) and the result is not an empty
% matrix.
function X = iProcessNonEmptyInputWithUnitDiffOrder(X, dim)

% Global output size is the input size decremented by one in
% the specified or derived dimension
outDims = size(X);
if isempty(dim)
    dim = distributedutil.Sizes.firstNonSingletonDimension(outDims);
end

xDist  = getCodistributor(X);

if ~xDist.hDiffCheck()
    error(message('parallel:codistributors:DiffUnsupported', class(xDist)));
end

localX = getLocalPart(X);
[localX, xDist] = xDist.hDiffImpl(localX, dim);
X = codistributed.pDoBuildFromLocalPart(localX, xDist); %#ok<DCUNK>
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process diff(X,N) and diff(X,N,Dim) and the result is not an empty matrix
function X = iProcessNonEmptyInput(X, n, dim)
for idx = 1:n
    X = iProcessNonEmptyInputWithUnitDiffOrder(X, dim);
end
end
