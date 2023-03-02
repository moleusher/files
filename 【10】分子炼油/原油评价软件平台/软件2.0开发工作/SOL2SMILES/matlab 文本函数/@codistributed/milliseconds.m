function ms = milliseconds(t)
%MILLISECONDS Create durations from numeric values in units of milliseconds.
%   
%   MS = MILLISECONDS(N)
%    
%   See also MILLISECONDS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

ms = codistributed.pElementwiseUnaryOp(@milliseconds, t);

