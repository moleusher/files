function Y = tanh(X)
%TANH Hyperbolic tangent of codistributed array
%   Y = TANH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = tanh(D)
%   end
%   
%   See also TANH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@tanh, X);
