function x = betaincinv(y,z,w,tail)
%BETAINCINV  Inverse incomplete beta function for codistributed arrays
%   X = BETAINCINV(Y,Z,W)
%   X = BETAINCINV(Y,Z,W,TAIL)
%   
%   Example:
%   spmd
%       N = 1000;
%       Y = 0.5;
%       Z = rand(N, 'codistributed');
%       W = 3;
%       betaincinv(Y,Z,W)
%   end
%   
%   See also BETAINCINV, CODISTRIBUTED/BETA, CODISTRIBUTED/BETAINC, CODISTRIBUTED.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

narginchk(3,4);

% The TAIL parameter should be a string and should always be gathered.
% Y, Z and W are all "data" so we use the ternary op helper.

if (nargin==3)
    fcn = @betaincinv;
else
    tail = distributedutil.CodistParser.gatherIfCodistributed(tail);
    fcn = @(a,b,c) betaincinv(a, b, c, tail);
end
 
x = codistributed.pElementwiseOp(fcn, y, z, w);

