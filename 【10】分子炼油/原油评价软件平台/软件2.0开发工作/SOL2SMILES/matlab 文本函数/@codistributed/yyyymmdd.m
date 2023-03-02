function y = yyyymmdd(t)
%YYYYMMDD Convert MATLAB datetimes to yyyymmdd numeric values.
%   
%   Y = YYYYMMDD(T)
%   
%   See also YYYYMMDD.
%   


%   Copyright 2016 The MathWorks, Inc.

y = codistributed.pElementwiseOp(@yyyymmdd, t);

