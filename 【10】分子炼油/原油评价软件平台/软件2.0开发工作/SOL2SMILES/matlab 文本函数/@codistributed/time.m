function t = time(d)
%TIME Extract the time portion of calendar durations.
%   
%   T = TIME(D)
%    
%   See also TIME, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

t = codistributed.pElementwiseUnaryOp(@time, d);

