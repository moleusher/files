function res = istriu( A )
%ISTRIU  Determine whether a codistributed matrix is upper triangular.
%   ISTRIU(X)
%   
%   Example:
%   spmd
%      X = codistributed(triu(magic(1000)));
%      istriu(X)
%   end
%   
%   See also ISTRIU, TRIU, MAGIC, CODISTRIBUTED.
%   


%   Copyright 2014-2016 The MathWorks, Inc.

% This function works for numerics, logicals and chars
if ~(isnumeric( A ) || islogical( A ) || ischar( A ))
    error(message('parallel:distributed:InvalidType','istriu',classUnderlying(A)))
end

res = checkFillPattern( A, {'UpperTriangular', 'Diagonal', 'ZeroMatrix'} );

end
