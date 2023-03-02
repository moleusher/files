function tf = isnat(t)
%ISNAT True for datetimes that are Not-a-Time.
%   
%   TF = ISNAT(T)
%   
%   See also ISNAT.
%   


%   Copyright 2016 The MathWorks, Inc.

tf = codistributed.pElementwiseOp(@isnat, t);

