function Y = round(X, N, mode)
%ROUND Round towards nearest integer for codistributed array
%   Y = ROUND(X)
%   Y = ROUND(X,N)
%   Y = ROUND(X,N,'significant')
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1, N)./2
%       E = round(D)
%   end
%   
%   See also ROUND, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS


%   Copyright 2006-2014 The MathWorks, Inc.

narginchk(1,3);

% The TAIL parameter should be a string and should always be gathered.
% Y, Z and W are all "data" so we use the ternary op helper.

switch nargin
    case 1
        fcn = @round;
    case 2
        N = distributedutil.CodistParser.gatherIfCodistributed(N);
        fcn = @(a) round(a,N);
    case 3
        N = distributedutil.CodistParser.gatherIfCodistributed(N);
        mode = distributedutil.CodistParser.gatherIfCodistributed(mode);
        fcn = @(a) round(a,N,mode);
end

Y = codistributed.pElementwiseUnaryOp(fcn, X);
