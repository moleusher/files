function t2 = dateshift(t, varargin)
%DATESHIFT Shift datetimes or generate sequences according to a calendar rule.
%   
%   T2 = DATESHIFT(T,'start',UNIT)
%   T2 = DATESHIFT(T,'end',UNIT)
%   T2 = DATESHIFT(T,'dayofweek',DOW)
%   T2 = DATESHIFT(T,...,RULE)
%   
%   See also DATESHIFT.
%   


%   Copyright 2016 The MathWorks, Inc.

% T must be a distributed datetime, the rest are gathered.
varargin = distributedutil.CodistParser.gatherElements(varargin);
 
t2 = codistributed.pElementwiseOp(@(a) dateshift(a, varargin{:}), t);

