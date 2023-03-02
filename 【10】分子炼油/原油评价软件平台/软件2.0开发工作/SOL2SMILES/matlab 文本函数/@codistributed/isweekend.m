function tf = isweekend(t)
%ISWEEKEND True for datetimes occurring on a weekend.
%   
%   TF = ISWEEKEND(T)
%   
%   See also ISWEEKEND.
%   


%   Copyright 2016 The MathWorks, Inc.

tf = codistributed.pElementwiseOp(@isweekend, t);

