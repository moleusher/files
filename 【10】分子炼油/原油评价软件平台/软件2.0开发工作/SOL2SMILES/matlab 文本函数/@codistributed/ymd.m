function [y,m,d] = ymd(t)
%YMD Year, month, and day numbers of datetimes.
%   
%   [Y,M,D] = YMD(T)
%   
%   See also YMD.
%   


%   Copyright 2016 The MathWorks, Inc.

[y,m,d] = codistributed.pElementwiseUnaryOp(@ymd, t);

