function y = year(t, varargin)
%YEAR Year numbers of datetimes.
%   
%   Y = YEAR(T)
%   Y = YEAR(T,KIND)
%   
%   See also YEAR.
%   


%   Copyright 2016 The MathWorks, Inc.

y = codistributed.pElementwiseUnaryOp(@year, t, varargin{:});

