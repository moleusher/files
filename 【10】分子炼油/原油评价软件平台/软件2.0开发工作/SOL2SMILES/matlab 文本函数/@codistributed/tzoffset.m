function [dt,dst] = tzoffset(t)
%TZOFFSET Time zone offset of datetimes.
%   
%   DT = TZOFFSET(T)
%   [DT,DST] = TZOFFSET(T)
%   
%   See also TZOFFSET.
%   


%   Copyright 2016 The MathWorks, Inc.

[dt,dst] = codistributed.pElementwiseUnaryOp(@tzoffset, t);

