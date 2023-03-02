function out = isduration( obj )
%ISDURATION True for durations.
%   
%   TF = ISDURATION(T)
%    
%   See also ISDURATION, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

out = isequal(classUnderlying(obj), 'duration');

end
