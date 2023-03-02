function varargout = trapz(varargin)
%TRAPZ Trapezoidal numerical integration.
%   Z = TRAPZ(Y)
%   Z = TRAPZ(X,Y)
%   Z = TRAPZ(...,DIM)
%   
%   Example:
%   spmd
%       % Create a sine wave between 0 and pi
%       X = codistributed.linspace(0, pi, 10000);
%       Y = sin(X);
%       Z = trapz(X,Y);  % == 2.0
%   end
%   
%   See also TRAPZ, CODISTRIBUTED, CODISTRIBUTED/SUM, CODISTRIBUTED/CUMSUM, CUMTRAPZ, INTEGRAL.


%   Copyright 2014 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.trapz(varargin{:});
catch ME
    throw(ME);
end
