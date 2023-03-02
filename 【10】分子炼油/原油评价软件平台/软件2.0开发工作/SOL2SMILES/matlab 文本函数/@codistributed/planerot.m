function varargout = planerot(varargin)
%PLANEROT   Givens plane rotation.
%   [G,Y] = PLANEROT(X)
%   
%   Example:
%   spmd
%       x = codistributed([1;2]);
%       [G,y] = planerot(x)
%   end


%   Copyright 2014 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.planerot(varargin{:});
catch ME
    throw(ME);
end
