function tod = timeofday(t)
%TIMEOFDAY Elapsed time since midnight for datetimes.
%   
%   D = TIMEOFDAY(T)
%   
%   See also TIMEOFDAY.
%   


%   Copyright 2016 The MathWorks, Inc.

tod = codistributed.pElementwiseOp(@timeofday, t);

