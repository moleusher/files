function m = minutes(t)
%MINUTES Create durations from numeric values in units of minutes.
%   
%   M = MINUTES(N)
%    
%   See also MINUTES, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

m = codistributed.pElementwiseUnaryOp(@minutes, t);

