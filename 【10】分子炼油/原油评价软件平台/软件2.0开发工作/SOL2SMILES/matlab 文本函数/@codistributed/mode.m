function varargout = mode(varargin)
%MODE   Mode, or most frequent value in a sample.
%   M = MODE(X)
%   [M,F] = MODE(X)
%   [M,F,C] = MODE(X)
%   [...] = MODE(X,DIM)
%   
%   Example:
%   spmd
%       % Random integers normally distributed around 0
%       y = fix(codistributed.randn(10000,10));
%       % Shift the center to 1..10
%       y = bsxfun(@plus, y, 1:10);
%       % Mode for each column is now 1:10
%       m = mode(y)
%   end
%   
%   See also MODE, MEDIAN, CODISTRIBUTED, CODISTRIBUTED/MEAN.


%   Copyright 2014 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.mode(varargin{:});
catch ME
    throw(ME);
end
