function dn = datenum(t)
%DATENUM Convert datetimes to serial date numbers.
%   
%   D = DATENUM(T)
%   
%   See also DATENUM.
%   


%   Copyright 2016 The MathWorks, Inc.

if isdatetime(t)  || isduration(t) || iscalendarduration(t) ...
        || isnumeric(t) || isstring(t) || iscellstr(t) || ischar(t)
    dn = codistributed.pDatetimeDurationCommon(@datenum, [3 6], t); %#ok<DCUNK>
    
else
    % Other types are not supported
    error(message('parallel:array:UnsupportedFunction', upper(mfilename), classUnderlying(t)));
    
end


