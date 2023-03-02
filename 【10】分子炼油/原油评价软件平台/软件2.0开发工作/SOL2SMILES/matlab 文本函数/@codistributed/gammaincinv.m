function x = gammaincinv(y,a,tail)
%GAMMAINCINV  Inverse incomplete gamma function for codistributed arrays
%   X = GAMMAINCINV(Y,A)
%   X = GAMMAINCINV(Y,A,TAIL)
%   
%   Example:
%   spmd
%       N = 1000;
%       Y = 0.5;
%       A = rand(N, 'codistributed');
%       gammaincinv(Y,A)
%   end
%   
%   See also GAMMAINCINV, CODISTRIBUTED/GAMMA, CODISTRIBUTED/GAMMAINC, CODISTRIBUTED.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

narginchk(2,3);

% The TAIL parameter should be a string and should always be gathered.
% Y and A are both "data" so we use the binary op helper.

if (nargin==2)
    fcn = @gammaincinv;
else
    tail = distributedutil.CodistParser.gatherIfCodistributed(tail);
    fcn = @(a,b) gammaincinv(a, b, tail);
end
 
x = codistributed.pElementwiseOp(fcn, y, a);

