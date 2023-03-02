function varargout = polyvalm(varargin)
%POLYVALM  Evaluate polynomial with matrix argument.
%   Y = polyvalm(P,X)
%   
%   Example:
%   spmd
%       P = codistributed([1 -29 72 -29 1]);
%       X = codistributed(magic(4)); 
%       polyvalm(P,X)
%   end
%   
%   See also POLYVALM, CODISTRIBUTED.


%   Copyright 2014-2016 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.polyvalm(varargin{:});
catch ME
    throw(ME);
end
