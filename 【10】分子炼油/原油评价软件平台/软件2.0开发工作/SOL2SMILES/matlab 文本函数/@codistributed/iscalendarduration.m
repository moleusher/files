function out = iscalendarduration( obj )
%ISCALENDARDURATION True for calendar durations.
%   
%   TF = ISCALENDARDURATION(T)
%    
%   See also ISCALENDARDURATION, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

out = isequal(classUnderlying(obj), 'calendarDuration');

end
