function varargout = find(varargin)
%FIND Find indices of nonzero elements of codistributed array
%   I = find(X)
%   I = find(X,K)
%   I = find(X,K,'first')
%   I = find(X,K,'last')
%   [I,J] = find(X,...)
%   [I,J,V] = find(X,...)
%   
%   Example:
%   spmd
%       N = 1000;
%       X = codistributed.rand(N) > 0.5 % build random array of ones and zeros
%       I = find(X) % find the indices where elements of X are non-zero
%   end
%   
%   See also FIND, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2016 The MathWorks, Inc.

narginchk(1, 3);

distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);

A = varargin{1};
argList = distributedutil.CodistParser.gatherElements(varargin(2:end));
if ~isa(A, 'codistributed')
    % Only the optional arguments were codistributed.
    [varargout{1:nargout}] = find(A, argList{:});
    return;
end

if nargin > 1
    k = argList{1};
    if ~isscalar(k) || (~isPositiveIntegerValuedNumeric(k) && k ~= inf)
        error(message('parallel:distributed:FindNotScalarInt'))
    end
end
if nargin > 2
    searchOpt = argList{2};
    if ~strcmpi(searchOpt,'first') && ~strcmpi(searchOpt,'last')
        error(message('parallel:distributed:FindInvalidOption'))
    end
end

needJ = nargout > 1;
needV = nargout > 2;
if nargout > 3
    error(message('parallel:distributed:FindMaxlhs'))
end

if isempty(A) && size(A,1) == 0 && size(A,2) == 0
    [varargout{1:nargout}] = handleEmptyAndScalarEdgeCase(A);
    return
end

aDist = getCodistributor(A);
if ~isa(aDist, 'codistributor1d') || (aDist.Dimension < ndims(A) && ~isvector(A))
    A = redistribute(A,codistributor('1d',ndims(A)));
    aDist = getCodistributor(A);
end
[e,ignore] = globalIndices(A, aDist.Dimension, labindex); %#ok<ASGLU> % Ignore the second output argument.
m = size(A,1);
if needV
    [i, j, v] = find(getLocalPart(A),varargin{2:nargin});
else
    [i, j] = find(getLocalPart(A),varargin{2:nargin});
end
if aDist.Dimension == 1
    i = i+e-1;
elseif aDist.Dimension == 2
    j = j+e-1;
else
    p = aDist.Partition;
    j = j+sum(p(1:labindex-1))*size(A,2);
end

% Get the sizes of all the local i's, j's and v's.
part = gcat(numel(i));

if isrow(A)
    % Input is a row vector, so i, j and v all have to be row vectors.
    sz = [1, sum(part)];
    dist = codistributor1d(2, part, sz);
    i = codistributed.pDoBuildFromLocalPart(i(:).', dist); %#ok<DCUNK> private method.
    j = codistributed.pDoBuildFromLocalPart(j(:).', dist); %#ok<DCUNK> private method.
    if needV
        v = codistributed.pDoBuildFromLocalPart(v(:).', dist); %#ok<DCUNK> private method.
    end

else
    % Input is not a row vector, so i, j and v all have to be column vectors.
    sz = [sum(part), 1];
    dist = codistributor1d(1, part, sz);
    i = codistributed.pDoBuildFromLocalPart(i(:), dist); %#ok<DCUNK> private method.
    j = codistributed.pDoBuildFromLocalPart(j(:), dist); %#ok<DCUNK> private method.
    if needV
        v = codistributed.pDoBuildFromLocalPart(v(:), dist); %#ok<DCUNK> private method.
    end

end
if nargin == 2 || ( nargin == 3 && strcmpi(searchOpt,'first') )
    s = substruct('()',{1:min(k,length(i))});
    i = subsref(i,s);
    j = subsref(j,s);
    if needV
        v = subsref(v,s);
    end
elseif nargin == 3 % && strcmpi(searchOpt,'last')
    len = length(i);
    s = substruct('()',{max(1,len-k+1):len});
    i = subsref(i,s);
    j = subsref(j,s);
    if needV
        v = subsref(v,s);
    end
end

if nargout <= 1
    i = i + (j-1)*m;
end

if isscalar(A) && isempty(i)
    [varargout{1:nargout}] = handleEmptyAndScalarEdgeCase(A);
else
    varargout{1} = i;
    if needJ
        varargout{2} = j;
        if needV
            varargout{3} = v;
        end
    end
end

function varargout = handleEmptyAndScalarEdgeCase(A)
%handle special find edge case
dist = codistributor1d(codistributor1d.unsetDimension, codistributor1d.defaultPartition(0), [0, 0]);
varargout{1} = zeros(0, dist);
if nargout > 1
    varargout{2} = varargout{1};
    if nargout > 2
        % We construct an empty array of the same class this way instead of
        % using the 'like' syntax because this way supports non-numeric types.
        emptyA = getLocalPart(A);
        emptyA(:) = [];
        if issparse(emptyA)
            emptyA = full(emptyA);
        end
        varargout{3} = codistributed.build(emptyA, dist);
    end
end
