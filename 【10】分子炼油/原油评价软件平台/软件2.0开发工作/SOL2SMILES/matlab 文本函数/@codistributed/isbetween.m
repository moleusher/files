function tf = isbetween(a, upper, lower)
%ISBETWEEN Determine if datetimes are contained in an interval.
%   
%   TF = ISBETWEEN(A,LOWER,UPPER)
%   
%   See also ISBETWEEN.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(3,3)

% Guard against character vectors
if ischar(upper)
    upper = datetime(upper);
end
if ischar(lower)
    lower = datetime(lower);
end

tf = codistributed.pElementwiseOp(@isbetween, a, upper, lower);

