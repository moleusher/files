function out = isnumeric( obj )
%ISNUMERIC True if codistributed array's underlying elements are numeric
%   TF = isnumeric(X) returns true if classUnderlying(X) is a 
%   built-in numeric type and false otherwise.
%   
%   Example:
%   spmd
%       D = codistributed(pi);
%       isnumeric(D) % returns true since PI has class double
%       L = codistributed(true);
%       isnumeric(L) % returns false since TRUE has class logical.
%   end
%   
%   See also ISNUMERIC, CLASSUNDERLYING, CODISTRIBUTED.
%   


%   Copyright 2012-2013 The MathWorks, Inc.

out = feval('_pctarray_isNumeric', classUnderlying(obj));

end
