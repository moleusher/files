function y = years(t)
%YEARS Create durations from numeric values in units of standard-length years.
%   
%   Y = YEARS(N)
%    
%   See also YEARS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

y = codistributed.pElementwiseUnaryOp(@years, t);

