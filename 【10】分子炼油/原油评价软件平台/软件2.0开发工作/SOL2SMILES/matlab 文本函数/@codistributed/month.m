function m = month(t, varargin)
%MONTH Month numbers or names of datetimes.
%   
%   M = MONTH(T)
%   
%   See also MONTH.
%   


%   Copyright 2016 The MathWorks, Inc.

m = codistributed.pElementwiseUnaryOp(@month, t, varargin{:});

