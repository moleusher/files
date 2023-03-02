function tf = isdst(t)
%ISDST True for datetimes occurring during Daylight Saving Time.
%   
%   TF = ISDST(T)
%   
%   See also ISDST.
%   


%   Copyright 2016 The MathWorks, Inc.

tf = codistributed.pElementwiseOp(@isdst, t);

