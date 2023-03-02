function out = isdatetime( obj )
%ISDATETIME True for datetimes.
%   
%   TF = ISDATETIME(T)
%    
%   See also ISDATETIME, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

out = isequal(classUnderlying(obj), 'datetime');

end
