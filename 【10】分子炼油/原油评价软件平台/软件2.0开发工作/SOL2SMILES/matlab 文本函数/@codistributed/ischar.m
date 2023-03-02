function out = ischar( obj )
%ISCHAR True for character codistributed array (string).
%   TF = ISCHAR(S)
%   
%   Example:
%   spmd
%       A = codistributed(['It was the best of times, it was the worst of times, ' ...
%       'it was the age of wisdom, it was the age of foolishness']);
%       t = ischar(A)
%   end
%   
%   See also ISCHAR, CODISTRIBUTED.
%   


%   Copyright 2015 The MathWorks, Inc.

out = isequal(classUnderlying(obj), 'char');

end
