function p = posixtime(t)
%POSIXTIME Convert datetimes to Posix times.
%   
%   P = POSIXTIME(T)
%   
%   See also POSIXTIME.
%   


%   Copyright 2016 The MathWorks, Inc.

p = codistributed.pElementwiseOp(@posixtime, t);

