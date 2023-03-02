function s = second(t, varargin)
%SECOND Second numbers of datetimes.
%   
%   S = SECOND(T)
%   S = SECOND(T,KIND)
%   
%   See also SECOND.
%   


%   Copyright 2016 The MathWorks, Inc.

s = codistributed.pElementwiseOp(@(a) second(a,varargin{:}), t);

