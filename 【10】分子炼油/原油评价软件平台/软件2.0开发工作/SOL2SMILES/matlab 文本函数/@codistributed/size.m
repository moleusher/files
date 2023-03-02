function varargout = size(D, dim)
%SIZE Size of codistributed array
%   S = SIZE(D), for the M-by-N codistributed array D, returns the two-element
%   row vector D = [M,N] containing the number of rows and columns in the
%   matrix. For N-D codistributed arrays, SIZE(D) returns a 1-by-N vector of
%   dimension lengths. Trailing singleton dimensions are ignored.
%   
%   [M,N] = SIZE(D) for codistributed array D, returns the number of rows and
%   columns in D as separate output variables.
%   
%   [M1,M2,M3,...,MN] = SIZE(D) for N>1 returns the sizes of the first N 
%   dimensions of the codistributed array D.  If the number of output arguments N does
%   not equal NDIMS(D), then for:
%   
%   N > NDIMS(D), SIZE returns ones in the "extra" variables, i.e., outputs
%                 NDIMS(D)+1 through N.
%   N < NDIMS(D), MN contains the product of the sizes of dimensions N
%                 through NDIMS(D).
%   
%   M = SIZE(D,DIM) returns the length of the dimension specified
%   by the scalar DIM.  For example, SIZE(D,1) returns the number
%   of rows. If DIM > NDIMS(D), M will be 1.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N, N*2);
%       n = size(D, 2)
%   end
%   
%   returns n = 2000.
%   
%   See also SIZE, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2016 The MathWorks, Inc.

varargout = cell(1,max(1,nargout));
try
    if nargin==1
        [varargout{:}] = distributedutil.Sizes.interpretSize(iGetSizeVec(D));
        
    else
        distributedutil.CodistParser.verifyNonCodistributedInputs({D, dim});
        [varargout{:}] = distributedutil.Sizes.interpretSize(iGetSizeVec(D), dim);
        
    end
    
catch err
    % Rethrow here to hide the stack
    throw(err);
end
end % size


function sz = iGetSizeVec(D)
if iscodistributed(D)
    dist = getCodistributor(D);
    sz = dist.Cached.GlobalSize;
else
    sz = size(D);
end
end
