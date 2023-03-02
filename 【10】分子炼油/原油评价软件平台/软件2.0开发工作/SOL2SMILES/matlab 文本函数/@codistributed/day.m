function d = day(t, varargin)
%DAY Day numbers or names of datetimes.
%   
%   D = DAY(T)
%   D = DAY(T,KIND)
%   
%   See also DAY.
%   


%   Copyright 2016 The MathWorks, Inc.

d = codistributed.pElementwiseUnaryOp(@day, t, varargin{:});

