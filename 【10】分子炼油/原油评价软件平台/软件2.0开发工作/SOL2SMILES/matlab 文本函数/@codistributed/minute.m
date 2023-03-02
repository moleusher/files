function m = minute(t)
%MINUTE Minute numbers of datetimes.
%   
%   M = MINUTE(T)
%   
%   See also MINUTE.
%   


%   Copyright 2016 The MathWorks, Inc.

m = codistributed.pElementwiseOp(@minute, t);

