function d = days(t)
%DAYS Create durations from numeric values in units of standard-length days.
%   
%   D = DAYS(N)
%    
%   See also DAYS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

d = codistributed.pElementwiseUnaryOp(@days, t);

