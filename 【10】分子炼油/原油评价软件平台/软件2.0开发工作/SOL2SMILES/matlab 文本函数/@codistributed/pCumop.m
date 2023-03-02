function P = pCumop(cumFcn, adjustFcn, initVal, A, varargin)
%pCumOp Template for CUMPROD and CUMSUM for codistributed array


%   Copyright 2006-2016 The MathWorks, Inc.

distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);
narginchk(4, 6); % Two optional args

% Set defaults for dimension and direction
dim = distributedutil.Sizes.firstNonSingletonDimension(size(A));
dirn = 'forward';

% Gather trailing arguments (if any) and work out which is which.
if nargin > 4
    args = distributedutil.CodistParser.gatherElements(varargin);
    % If only one optional arg, it can be either a direction (char) or
    % dimension. Anything except char is assumed to be a dimension.
    if numel(args)==1
        if ischar(args{1})
            dirn = args{1};
        else
            dim = args{1};
        end
    else % numel(args)==2
        dim = args{1};
        dirn = args{2};
    end
end

% Check that we aren't trying to do maths on complex integers
if isinteger(A) && ~isreal(A)
    ME = MException(['MATLAB:',func2str(cumFcn),':complexIntegers'], ...
        getString(message('MATLAB:cumfun:complexIntegers')));
    throwAsCaller(ME);
end

% Check that DIM and DIRN are valid
if ~isscalar(dim) || ~isPositiveIntegerValuedNumeric(dim)
    ME = MException(message(...
        'parallel:distributed:dimensionMustBePositiveInteger'));
    throwAsCaller(ME);
end
if ~ischar(dirn) || isempty(dirn) || length(dirn)>7 ...
        || (~strncmpi(dirn,'forward',length(dirn)) && ~strncmpi(dirn,'reverse',length(dirn)))
    ME = MException(message('MATLAB:cumfun:wrongDirection'));
    throwAsCaller(ME);
end
isReverse = (upper(dirn(1))=='R');

% Call the normal MATLAB version if the data is on the host
if ~isa(A, 'codistributed')
    try
        P = cumFcn(A, dim, dirn);
        return;
    catch E
        throwAsCaller(E);
    end
end

try
    % This implementation only supports codistributor1d.
    codistributed.pVerifyUsing1d(func2str(cumFcn), A); %#ok<DCUNK> private static
catch E
    % Error stack should only show cumprod or cumsum, not pCumop.
    throwAsCaller(E);
end

if size(A,dim) == 1 || isempty(A)
    %cumop on a singleton dimension.
    P = A;
else
    % cumop on a non-singleton dimension
    % first accumulate the local part
    localP = cumFcn(getLocalPart(A), dim, dirn);
    
    % If the accumulation dimension is the distribution dimension we
    % also need to adjust for previous totals.
    aDist = getCodistributor(A);
    if aDist.Dimension == dim
        localP = iAdjustLocalPart(localP, adjustFcn, initVal, ndims(A), dim, isReverse);
    end
    P = codistributed.pDoBuildFromLocalPart(localP, aDist); %#ok<DCUNK> private method.
end
end % pCumOp


function localP = iAdjustLocalPart(localP, adjustFcn, initVal, ndimsA, dim, isReverse)
% Adjust the values in this local part using the final values from
% previous local parts.

% Form an index expression that will extract the values from each page
pageindex = cell(1,ndimsA);
[pageindex{:}] = deal(':');
if ~isempty(localP)
    if isReverse
        % We want the first element from each local part
        pageindex{dim} = 1;
    else
        % We want the final element from each local part
        pageindex{dim} = size(localP,dim);
    end
end
% Extract final values on each lab
scale = gcat({localP(pageindex{:})}, dim);

if ~isempty(localP)
    setcumscale = false;
    
    % Initialize cumscale and make sure it has the same sparsity as the
    % local part.
    if issparse(localP) 
        cumscale = sparse(initVal);
    else
        cumscale = full(initVal);
    end
    
    % Scan all the preceding labs to build up the scaling factor
    if isReverse
        labsToScan = labindex+1:numlabs;
    else
        labsToScan = 1:labindex-1;
    end
    for ii = labsToScan
        if ~isempty(scale{ii})
            cumscale = adjustFcn(scale{ii}, cumscale);
            setcumscale = true;
        end
    end
    % If any lab set the scaling factor, apply it to our local part
    if setcumscale
        localP = adjustFcn(localP, iExpandToMatch(cumscale,localP,dim,ndimsA));
    end
end
end % iAdjustLocalPart


function  expandX = iExpandToMatch(reducedX,X,dim,ndimsA)
s = ones(1, ndimsA);
s(dim) = size(X,dim);
expandX = repmat(reducedX,s);
end % iExpandToMatch