function out = islogical( obj )
%ISLOGICAL True for logical codistributed array
%   TF = ISLOGICAL(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       A = codistributed.ones(N);
%       f = islogical(A)
%       t = islogical(A > 0)
%   end
%   
%   returns f = false and t = true.
%   
%   See also ISLOGICAL, CODISTRIBUTED, CODISTRIBUTED/ONES.
%   


%   Copyright 2010-2013 The MathWorks, Inc.

out = feval('_pctarray_isLogical', classUnderlying(obj));

end
