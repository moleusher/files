function y = psi(K, X)
%PSI  Psi (polygamma) function for codistributed arrays
%   Y = PSI(X)
%   Y = PSI(K,X)
%   
%   Example:
%   spmd
%       N = 1000;
%       K = 1;
%       X = 10*rand(N, 'codistributed');
%       psi(K,X)
%   end
%   
%   See also PSI, CODISTRIBUTED/GAMMA, CODISTRIBUTED.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

narginchk(1, 2); % K is optional

% The K parameter (if provided) should be scalar and can be gathered.
if nargin>1
    if ~isscalar(K)
        error(message('MATLAB:psi:kScalar'));
    end
    K = distributedutil.CodistParser.gatherIfCodistributed(K);
    
    fcncall = @(a) psi(K, a);
else
    X = K;
    fcncall = @psi;
end
 
try
    y = codistributed.pElementwiseOp(fcncall, X);
    return;
catch E
    throwAsCaller(E);
end

