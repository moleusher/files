function y = calyears(t)
%CALYEARS Create calendar durations from numeric values in units of calendar years.
%   
%   Y = CALYEARS(N)
%    
%   See also CALYEARS, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

y = codistributed.pElementwiseUnaryOp(@calyears, t);

