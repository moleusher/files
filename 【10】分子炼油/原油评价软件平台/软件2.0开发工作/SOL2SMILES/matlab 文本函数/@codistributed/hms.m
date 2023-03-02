function [h,m,s] = hms(t)
%HMS Hour, minute, and second numbers of datetimes.
%   
%   [H,M,S] = HMS(T)
%   
%   See also HMS.
%   


%   Copyright 2016 The MathWorks, Inc.

[h,m,s] = codistributed.pElementwiseUnaryOp(@hms, t);

