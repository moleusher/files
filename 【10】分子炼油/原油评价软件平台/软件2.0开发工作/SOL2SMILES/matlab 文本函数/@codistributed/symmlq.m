function varargout = symmlq(varargin)
%SYMMLQ   Symmetric LQ Method for codistributed array.
%   X = SYMMLQ(A,B)
%   X = SYMMLQ(A,B)
%   X = SYMMLQ(A,B,TOL)
%   X = SYMMLQ(A,B,TOL,MAXIT)
%   X = SYMMLQ(A,B,TOL,MAXIT,M)
%   X = SYMMLQ(A,B,TOL,MAXIT,M1,M2)
%   X = SYMMLQ(A,B,TOL,MAXIT,M1,M2,X0)
%   [X,FLAG] = SYMMLQ(A,B,...)
%   [X,FLAG,RELRES] = SYMMLQ(A,B,...)
%   [X,FLAG,RELRES,ITER] = SYMMLQ(A,B,...)
%   [X,FLAG,RELRES,ITER,RESVEC] = SYMMLQ(A,B,...)
%      
%   Note that B must be a non-sparse column vector.
%   
%   Example:
%   Using SYMMLQ to solve a large system of codistributed array data:
%   spmd
%       n = 1e6; 
%       on = ones(n,1); 
%       A = spdiags([-2*on 4*on -on],-1:1,n,n);
%       b = full(sum(A,2)); 
%       tol = 1e-8; 
%       maxit = 15; 
%       
%       dA = codistributed(A);
%       db = codistributed(b);
%       x = SYMMLQ(dA,db,tol,maxit)
%   end
%   
%   See also SYMMLQ, CODISTRIBUTED.


%   Copyright 1984-2014 The MathWorks, Inc.

% Ensure that only the data inputs (args 1,2,5,6,7) are distributed
isData = [1 1 0 0 1 1 1];
varargin = distributedutil.CodistParser.prepareSolverInputs(varargin, isData);

% Call the local copy of the MATLAB code
[varargout{1:nargout}] = parallel.internal.flowthrough.symmlq(varargin{:});
