function varargout = idivide(varargin)
%IDIVIDE  Integer division with rounding option.
%   C = IDIVIDE(A,B)
%   C = IDIVIDE(A,B,OPT)
%   
%   Example:
%   spmd
%       a = codistributed(int32([-2 2]));
%       b = codistributed(int32(3));
%       idivide(a,b) % returns [0 0]
%       idivide(a,b,'floor') % returns [-1 0]
%       idivide(a,b,'ceil') % returns [0 1]
%       idivide(a,b,'round') % returns [-1 1]
%   end
%   
%   See also IDIVIDE, CODISTRIBUTED, CODISTRIBUTED/INT32.


%   Copyright 2014-2016 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.idivide(varargin{:});
catch ME
    throw(ME);
end
