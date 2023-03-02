function w = week(t, varargin)
%WEEK Week numbers of datetimes.
%   
%   W = WEEK(T)
%   W = WEEK(T,KIND)
%   
%   See also WEEK.
%   


%   Copyright 2016 The MathWorks, Inc.

w = codistributed.pElementwiseOp(@(a) week(a,varargin{:}), t);

