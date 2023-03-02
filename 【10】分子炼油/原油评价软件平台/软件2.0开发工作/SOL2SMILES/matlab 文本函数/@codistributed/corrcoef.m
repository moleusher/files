function varargout = corrcoef(varargin)
%CORRCOEF Correlation coefficients.
%   R = CORRCOEF(X)
%   R = CORRCOEF(X,Y)
%   [R,P] = CORRCOEF(...)
%   [R,P,RLO,RUP] = CORRCOEF(...)
%   [...] = CORRCOEF(...,'PARAM1',VAL1,'PARAM2',VAL2,...)
%   
%   Example:
%   spmd
%       X = rand(10000, 10, 'codistributed'); % Uncorrelated data
%       X(:,4) = sum(X, 2); % Introduce correlation
%       R = corrcoef(X);    % Compute sample correlation
%   end
%   
%   See also CORRCOEF, CODISTRIBUTED, COV, CODISTRIBUTED/VAR, STD.


%   Copyright 2013-2014 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.corrcoef(varargin{:});
catch ME
    throw(ME);
end
