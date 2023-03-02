function varargout = factorial(varargin)
%FACTORIAL Factorial function.
%   F = FACTORIAL(N)
%   
%   64-bit integer input is not supported.
%   
%   Example:
%   spmd
%       N = randi(100, 100000, 1, 'codistributed'); % Random integers up to 100
%       F = factorial(N);
%   end
%   
%   See also FACTORIAL, CODISTRIBUTED, CODISTRIBUTED/PROD.


%   Copyright 2014-2016 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.factorial(varargin{:});
catch ME
    throw(ME);
end
