function q = calquarters(t)
%CALQUARTERS Create calendar durations from numeric values in units of calendar quarters.
%   
%   Q = CALQUARTERS(N)
%    
%   See also CALQUARTERS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

q = codistributed.pElementwiseUnaryOp(@calquarters, t);

