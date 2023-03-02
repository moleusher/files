function s = seconds(t)
%SECONDS Create durations from numeric values in units of seconds.
%   
%   S = SECONDS(N)
%    
%   See also SECONDS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

s = codistributed.pElementwiseUnaryOp(@seconds, t);

