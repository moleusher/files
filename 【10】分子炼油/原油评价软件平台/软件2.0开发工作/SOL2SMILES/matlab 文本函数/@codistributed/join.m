function out = join(in, varargin)
%JOIN Combine elements of a string array together
%   
%   S = JOIN(STR)
%   S = JOIN(STR,DELIMITER)
%   S = JOIN(STR,DIM)
%   S = JOIN(STR,DELIMITER,DIM)
%   
%   See also JOIN.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(1,3);

if ~isstring(in)
    error(message('parallel:array:UnsupportedFunction', upper(mfilename), classUnderlying(in)));
end

distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);
varargin = distributedutil.CodistParser.gatherElements(varargin);
if ~isa(in, 'codistributed')
    out = join(in, varargin{:});
    return;
end

gotDelimiter = false;

switch(nargin)
    case 3
        delim = varargin{1};
        dim = varargin{2};
        fcn = @(x,d) iJoin(x,delim,d);
        gotDelimiter = true;

    case 2
        % Work out whether we have a dimension or delimiter
        if isnumeric(varargin{1})
            dim = varargin{1};
            fcn = @iJoin;
        else
            % Treat as delimiter and set dim=0 (magic value that means
            % "work it out later")
            delim = varargin{1};
            gotDelimiter = true;
            dim = 0;
            fcn = @(x,d) iJoin(x,delim,d);
        end
        
    case 1
        dim = 0;
        fcn = @iJoin;
end

if ~isnumeric(dim) || ~isscalar(dim) || dim<0 || dim~=floor(dim) || dim ~= real(dim)
    error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
end

% Standard reductions operate along the first non-singleton dimension if
% none is specified. This function operates along the last, so we must
% specify the dimension in order to use the normal helpers.
if dim == 0
    gsize = size(in);
    dim = find(gsize~=1, 1, 'last');
    if isempty(dim)
        dim = 1;
    end
end

if gotDelimiter
    iValidateDelimiter(delim, dim, size(in));

    if ~ischar(delim) && ~isscalar(delim)
        % For a non-scalar delimiter, redistribute to ensure that the delimiter has size
        % 1 in the distribution dimension (to ensure no further errors from JOIN).
        delimSz = size(delim);
        distDim = find(delimSz == 1, 1, 'first');
        if isempty(distDim)
            distDim = 1 + numel(delimSz);
        end
        
        % Carefully try to avoid redistribution if possible.
        newDistributor = codistributor1d(distDim, codistributor1d.unsetPartition, size(in));
        in = redistributeIfNeeded(in, newDistributor);
    end
end
    
if size(in, dim) == 0
    % In this case, we can ignore the delimiter and must use JOIN directly to end up
    % with the appropriate <missing> result.
    out = codistributed.pReductionOpAlongDim(@join, in, dim);
else
    out = codistributed.pReductionOpAlongDim(fcn, in, dim);
    % The reduction must not result in a size of zero in the reduction dimension.
    assert(size(out, dim) ~= 0);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check that the delimiter type is OK, and the size is OK given the input size
% and reduction dimension
function iValidateDelimiter(delim, dim, input_dims)
% First, validate the class of the delimiter
isCharVector = @(x) ischar(x) && isrow(x);
if isCharVector(delim) || isstring(delim)
    % OK
elseif iscell(delim)
    if all(cellfun(isCharVector, delim(:)))
        % OK
    else
        error(message('MATLAB:string:CellInputMustBeCellArrayOfStrings'));
    end
else
    % Delimiter is always the second input to JOIN.
    secondInput = getString(message('MATLAB:string:SecondInput'));
    error(message('MATLAB:string:MustBeCharCellArrayOrString', secondInput));
end

% Next, validate the size of the delimiter, following
% 'errorIfDelimterIsWrongSize' [sic]
if ischar(delim) || isscalar(delim)
    % No work to do for scalar delimiter
else
    input_ndims = numel(input_dims);
    delimiter_ndims = ndims(delim);
    delimiter_dims = size(delim);
    
    if input_ndims ~= delimiter_ndims
        error(message('MATLAB:string:InvalidDelimiterDimensions'));
    end
    % If the delimiter is scalar in any dimension, that's fine
    ok = delimiter_dims == 1;

    % In the reduction dimension, it's also OK for the delimiter to be 1 less
    ok(dim) = ok(dim) | input_dims(dim) - 1 == delimiter_dims(dim);
    
    % In dimensions other than the reduction dimension, it's OK for the delimiter to
    % match
    notDim = (1:input_ndims) ~= dim;
    ok(notDim) = ok(notDim) | input_dims(notDim) == delimiter_dims(notDim);
    
    if ~all(ok)
        error(message('MATLAB:string:InvalidDelimiterDimensions'));
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Join - but ignore local parts that have size 0 in the reduction dimension, and
% return them unmodified.
function out = iJoin(x, varargin)
dim = varargin{end};
if size(x, dim) == 0
    % Override output
    out = x;
else
    out = join(x, varargin{:});
end
end
