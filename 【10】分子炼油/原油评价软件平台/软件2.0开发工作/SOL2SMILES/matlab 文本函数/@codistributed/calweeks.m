function w = calweeks(t)
%CALWEEKS Create calendar durations from numeric values in units of calendar weeks.
%   
%   W = CALWEEKS(N)
%    
%   See also CALWEEKS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

w = codistributed.pElementwiseUnaryOp(@calweeks, t);

