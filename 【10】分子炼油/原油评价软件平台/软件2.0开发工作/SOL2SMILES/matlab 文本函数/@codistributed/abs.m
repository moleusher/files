function Y = abs(X)
%ABS Absolute value of codistributed array
%   Y = ABS(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = complex(3*codistributed.ones(N),4*codistributed.ones(N))
%       absD = abs(D)
%   end
%   
%   compare with
%   absD2 = sqrt(real(D).^2 + imag(D).^2)
%   
%   See also ABS, CODISTRIBUTED.


%   Copyright 2006-2011 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@abs, X);
