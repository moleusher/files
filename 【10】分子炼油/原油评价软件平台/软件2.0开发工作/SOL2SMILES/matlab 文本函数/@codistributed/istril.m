function res = istril( A )
%ISTRIL  Determine whether a codistributed matrix is lower triangular.
%   ISTRIL(X)
%   
%   Example:
%   spmd
%      X = codistributed(tril(magic(1000)));
%      istril(X)
%   end
%   
%   See also ISTRIL, TRIL, MAGIC, CODISTRIBUTED.
%   


%   Copyright 2014-2016 The MathWorks, Inc.

% This function works for numerics, logicals and chars
if ~(isnumeric( A ) || islogical( A ) || ischar( A ))
    error(message('parallel:distributed:InvalidType','istril',classUnderlying(A)))
end

res = checkFillPattern( A, {'LowerTriangular', 'Diagonal', 'ZeroMatrix'} );

end
