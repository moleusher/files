function D = rad2deg(R)
%RAD2DEG Convert angles from radians to degrees.
%   D = RAD2DEG(R)
%   
%   Example:
%   spmd
%       n = 1000;
%       r = codistributed.linspace(0,pi,n);
%       d = rad2deg(r)
%   end
%   
%   See also RAD2DEG, CODISTRIBUTED, CODISTRIBUTED/LINSPACE.


%   Copyright 2015 The MathWorks, Inc.

D = codistributed.pElementwiseUnaryOp(@rad2deg, R);
