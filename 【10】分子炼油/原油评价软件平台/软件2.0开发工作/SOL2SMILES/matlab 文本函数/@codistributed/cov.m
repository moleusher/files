function varargout = cov(varargin)
%COV Covariance matrix.
%   C = COV(X) or COV(X,0)
%   C = COV(X,1)
%   C = COV(X,Y) 
%   C = COV(X,Y,0)
%   C = COV(X,Y,1)
%   C = COV(..., MISSING)
%   
%   Example:
%   spmd
%       Nrow = 50;
%       Ncol = 100; 
%       X = rand(Nrow, Ncol, 'codistributed');
%       xy = cov(X);     % Returns a 100 by 100 matrix
%       Y = rand(Nrow, Ncol, 'codistributed');
%       xy = cov(X,Y);   % Returns a 2 by 2 matrix
%   end
%   
%   X and Y must be single or double matrices. Both real and
%   complex types are supported.
%   
%   See also COV, CODISTRIBUTED, CODISTRIBUTED/CORRCOEF, CODISTRIBUTED/VAR, STD, MEAN.


%   Copyright 2010-2014 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.cov(varargin{:});
catch ME
    throw(ME);
end
