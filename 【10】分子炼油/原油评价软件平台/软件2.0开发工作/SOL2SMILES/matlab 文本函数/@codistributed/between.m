function d = between(t1,t2,components)
%BETWEEN Difference between datetimes as calendar durations.
%   
%   D = BETWEEN(T1,T2)
%   D = BETWEEN(T1,T2,COMPONENTS)
%   
%   See also BETWEEN.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2,3);

% The COMPONENTS parameter should be a string and should always be gathered.
% T1 and T2 are both "data" so we use a binary element-wise op.
if (nargin==2)
    fcn = @between;
else
    components = distributedutil.CodistParser.gatherIfCodistributed(components);
    fcn = @(a,b) between(a, b, components);
end
 
d = codistributed.pElementwiseOp(fcn, t1, t2);

