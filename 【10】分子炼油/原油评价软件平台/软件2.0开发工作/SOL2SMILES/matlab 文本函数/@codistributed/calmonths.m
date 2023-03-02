function m = calmonths(t)
%CALMONTHS Create calendar durations from numeric values in units of calendar months.
%   
%   M = CALMONTHS(N)
%    
%   See also CALMONTHS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

m = codistributed.pElementwiseUnaryOp(@calmonths, t);

