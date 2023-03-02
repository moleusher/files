function varargout = var(varargin)
%VAR Variance.
%   Y = VAR(X) or VAR(X,0)
%   Y = VAR(X,1)
%   Y = VAR(X,W)
%   Y = VAR(X,W,DIM)
%   Y = VAR(...,'omitnan')
%   Y = VAR(...,'includenan')
%   
%   Example:
%   spmd
%       Nrow = 50;
%       Ncol = 100; 
%       X = codistributed.rand(Nrow, Ncol);
%       W1 = codistributed.rand(1, Ncol);
%       Y1 = var(X,W1,2); % Returns a 50 by 1 vector
%       W2 = codistributed.rand(Nrow, 1); 
%       Y2 = var(X,W2,1); % Returns a 1 by 100 vector
%   end
%   
%   X and Y must be single or double arrays. Both real and complex types are supported.
%   
%   See also VAR, CODISTRIBUTED, MEAN, STD, COV, CODISTRIBUTED/CORRCOEF.
%   


%   Copyright 2010-2014 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.var(varargin{:});
catch ME
    throw(ME);
end
