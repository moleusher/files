function h = hour(t)
%HOUR Hour numbers of datetimes.
%   
%   H = HOUR(T)
%   
%   See also HOUR.
%   


%   Copyright 2016 The MathWorks, Inc.

h = codistributed.pElementwiseOp(@hour, t);

