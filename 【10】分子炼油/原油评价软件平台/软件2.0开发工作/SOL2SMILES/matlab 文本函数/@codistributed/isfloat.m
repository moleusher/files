function out = isfloat( obj )
%ISFLOAT True if codistributed array's underlying elements are floating-point
%   TF = isfloat(X) returns true if classUnderlying(X) is a
%   floating-point data type and false otherwise.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed(N);
%       t = isfloat(D)
%   end
%   
%   returns t = true.
%   
%   See also ISFLOAT, CLASSUNDERLYING, CODISTRIBUTED.
%   


%   Copyright 2012-2013 The MathWorks, Inc.

out = feval('_pctarray_isFloat', classUnderlying(obj));

end
