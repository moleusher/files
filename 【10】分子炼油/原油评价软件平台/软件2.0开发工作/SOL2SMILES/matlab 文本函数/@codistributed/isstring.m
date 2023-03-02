function out = isstring( obj )
%ISSTRING True for string codistributed array.
%   TF = ISSTRING(S)
%   
%   See also ISSTRING, CODISTRIBUTED.
%   


%   Copyright 2016 The MathWorks, Inc.

out = isequal(classUnderlying(obj), 'string');

end
