function Y = conj(X)
%CONJ Complex conjugate of codistributed array
%   Y = CONJ(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = complex(3*codistributed.ones(N),4*codistributed.ones(N))
%       E = conj(D)
%   end
%   
%   See also CONJ, CODISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@conj, X);
