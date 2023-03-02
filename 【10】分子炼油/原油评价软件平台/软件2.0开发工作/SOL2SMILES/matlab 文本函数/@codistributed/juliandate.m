function jd = juliandate(t, varargin)
%JULIANDATE Convert datetimes to Julian dates.
%   
%   J = JULIANDATE(T)
%   J = JULIANDATE(T,'modifiedjuliandate')
%   
%   See also JULIANDATE.
%   


%   Copyright 2016 The MathWorks, Inc.

jd = codistributed.pElementwiseUnaryOp(@juliandate, t, varargin{:});

