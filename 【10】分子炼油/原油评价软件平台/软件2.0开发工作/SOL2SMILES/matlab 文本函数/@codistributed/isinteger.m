function out = isinteger( obj )
%ISINTEGER True if codistributed array's underlying elements are integer
%   TF = isinteger(X) returns true if classUnderlying(X) is an
%   integer data type and false otherwise.
%   
%   Example:
%   spmd
%       N = int8(10);
%       D = codistributed(N);
%       t = isinteger(D)
%   end
%   
%   returns t = true.
%   
%   See also ISINTEGER, CLASSUNDERLYING, CODISTRIBUTED.
%   


%   Copyright 2012-2013 The MathWorks, Inc.

out = feval('_pctarray_isInteger', classUnderlying(obj));

end
