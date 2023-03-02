function Y = expint(X)
%NTHROOT Exponential integral function.
%       Y = expint(X) 
%   
%   Example:
%   spmd
%       N = 1000;
%       V = codistributed.rand(N);
%       F = expint(V);
%   end
%   
%   See also EXPINT, CODISTRIBUTED, CODISTRIBUTED/RAND.
%   


%   Copyright 2015 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@expint, X);
