function R = deg2rad(D)
%DEG2RAD Convert angles from degrees to radians.
%   R = DEG2RAD(D)
%   
%   Example:
%   spmd
%       n = 1000;
%       d = codistributed.linspace(0,180,n);
%       r = deg2rad(d)
%   end
%   
%   See also DEG2RAD, CODISTRIBUTED, CODISTRIBUTED/LINSPACE.


%   Copyright 2015 The MathWorks, Inc.

R = codistributed.pElementwiseUnaryOp(@deg2rad, D);
