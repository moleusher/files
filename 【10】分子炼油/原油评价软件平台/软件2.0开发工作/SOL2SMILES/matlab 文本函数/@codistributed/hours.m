function h = hours(t)
%HOURS Create durations from numeric values in units of hours.
%   
%   H = HOURS(N)
%    
%   See also HOURS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

h = codistributed.pElementwiseUnaryOp(@hours, t);

