function Y = acsc(X)
%ACSC Inverse cosecant of codistributed array, result in radian
%   Y = ACSC(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.ones(N);
%       E = acsc(D)
%   end
%   
%   See also ACSC, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2013 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@acsc, X);
