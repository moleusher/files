function Y = csch(X)
%CSCH Hyperbolic cosecant of codistributed array
%   Y = CSCH(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.inf(N);
%       E = csch(D)
%   end
%   
%   See also CSCH, CODISTRIBUTED, CODISTRIBUTED/INF.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@csch, X);
