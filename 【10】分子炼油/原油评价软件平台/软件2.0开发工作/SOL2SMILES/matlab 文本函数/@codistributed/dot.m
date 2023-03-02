function c = dot(a,b,dim)
%DOT Vector dot product of codistributed array
%   C = DOT(A,B)
%   C = DOT(A,B,DIM)
%   
%   Example:
%   spmd
%       N = 1000;
%       d1 = codistributed.colon(1,N);
%       d2 = codistributed.ones(N,1);
%       d = dot(d1,d2)
%   end
%   
%   returns d = N*(N+1)/2.
%   
%   See also DOT, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ONES.


%   Copyright 2006-2016 The MathWorks, Inc.

narginchk(2, 3);

if nargin == 2
    distributedutil.CodistParser.verifyNonCodistributedInputs({a, b});
elseif nargin == 3 
    distributedutil.CodistParser.verifyNonCodistributedInputs({a, b, dim});
    dim = distributedutil.CodistParser.gatherIfCodistributed(dim);
    if ~isa(a, 'codistributed') && ~isa(b, 'codistributed')
        c = dot(a, b, dim);
        return;
    end
end

% Special case: A and B are vectors and dim not supplied
if isvector(a) && isvector(b) && nargin<3
    % Ensure that a and b are either both column vectors or both row vectors.
    isColVec = @(v) size(v, 1) > 1;
    if isColVec(a) ~= isColVec(b)
        b = b.';
    end
    % The binary operation .* does a redistribution if necessary. Note that 
    % the result is scalar but still distributed.
    c = sum(conj(a).*b);
    return;
end

% Check dimensions
if ~isequal(size(a), size(b))
   error(message('parallel:distributed:DotInputSizeMismatch'));
end

if nargin==2
  c = sum(conj(a).*b);
else
  c = sum(conj(a).*b, dim);
end
