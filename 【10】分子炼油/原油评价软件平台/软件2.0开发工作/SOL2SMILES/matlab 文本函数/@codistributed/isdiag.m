function res = isdiag( A )
%ISDIAG  Determine whether a codistributed matrix is diagonal.
%   ISDIAG(X)
%   
%   Example:
%   spmd
%      X = codistributed.eye(1000);
%      isdiag(X)
%   end
%   
%   See also ISDIAG, CODISTRIBUTED, CODISTRIBUTED.EYE.
%   


%   Copyright 2014-2016 The MathWorks, Inc.

% This function works for numerics, logicals and chars
if ~(isnumeric( A ) || islogical( A ) || ischar( A ))
    error(message('parallel:distributed:InvalidType','isdiag',classUnderlying(A)))
end

res = checkFillPattern( A, {'Diagonal', 'ZeroMatrix'} );

end
