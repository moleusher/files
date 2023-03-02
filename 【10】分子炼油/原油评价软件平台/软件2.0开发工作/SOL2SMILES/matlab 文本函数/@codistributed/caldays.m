function d = caldays(t)
%CALDAYS Create calendar durations from numeric values in units of calendar days.
%   
%   D = CALDAYS(N)
%    
%   See also CALDAYS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

d = codistributed.pElementwiseUnaryOp(@caldays, t);

