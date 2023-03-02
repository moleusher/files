function y = betainc(x,z,w,tail)
%BETAINC  Incomplete beta function for codistributed arrays
%   Y = BETAINC(X,Z,W)
%   Y = BETAINC(X,Z,W,TAIL)
%   
%   Example:
%   spmd
%       N = 1000;
%       X = 0.5;
%       Z = rand(N, 'codistributed');
%       W = 3;
%       betainc(X,Z,W)
%   end
%   
%   See also BETAINC, CODISTRIBUTED/BETA, CODISTRIBUTED/BETAINCINV, CODISTRIBUTED.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

narginchk(3,4);

% The TAIL parameter should be a string and should always be gathered.
% Y, Z and W are all "data" so we use the ternary op helper.

if (nargin==3)
    fcn = @betainc;
else
    tail = distributedutil.CodistParser.gatherIfCodistributed(tail);
    fcn = @(a,b,c) betainc(a, b, c, tail);
end
 
y = codistributed.pElementwiseOp(fcn, x, z, w);

