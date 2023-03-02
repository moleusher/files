function e = exceltime(t, varargin)
%EXCELTIME Convert datetimes to Excel serial date numbers.
%   
%   E = EXCELTIME(T)
%   E = EXCELTIME(T,'1904')
%   
%   See also EXCELTIME.
%   


%   Copyright 2016 The MathWorks, Inc.

e = codistributed.pElementwiseUnaryOp(@exceltime, t, varargin{:});

