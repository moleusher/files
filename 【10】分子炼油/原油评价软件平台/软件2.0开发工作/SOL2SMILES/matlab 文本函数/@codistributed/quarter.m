function q = quarter(t)
%QUARTER Quarter numbers of datetimes.
%   
%   Q = QUARTER(T)
%   
%   See also QUARTER.
%   


%   Copyright 2016 The MathWorks, Inc.

q = codistributed.pElementwiseOp(@quarter, t);

