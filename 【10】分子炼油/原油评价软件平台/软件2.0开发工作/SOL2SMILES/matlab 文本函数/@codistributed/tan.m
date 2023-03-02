function Y = tan(X)
%TAN Tangent of codistributed array in radians
%   Y = TAN(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = pi/4*codistributed.ones(N);
%       E = tan(D)
%   end
%   
%   See also TAN, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@tan, X);
