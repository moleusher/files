function y = gammainc(x,a,tail)
%GAMMAINC  Incomplete gamma function for codistributed arrays
%   Y = GAMMAINC(X,A)
%   Y = GAMMAINC(X,A,TAIL)
%   
%   Example:
%   spmd
%       N = 1000;
%       X = 0.5;
%       A = rand(N, 'codistributed');
%       gammainc(X,A)
%   end
%   
%   See also GAMMAINC, CODISTRIBUTED/GAMMA, CODISTRIBUTED/GAMMAINCINV, CODISTRIBUTED.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

narginchk(2,3);

% The TAIL parameter should be a string and should always be gathered.
% X and A are both "data" so we use the binary op helper.

if (nargin==2)
    fcn = @gammainc;
else
    tail = distributedutil.CodistParser.gatherIfCodistributed(tail);
    fcn = @(a,b) gammainc(a, b, tail);
end
 
y = codistributed.pElementwiseOp(fcn, x, a);

