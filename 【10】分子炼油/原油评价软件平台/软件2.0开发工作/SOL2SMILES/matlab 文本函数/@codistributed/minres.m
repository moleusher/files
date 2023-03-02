function varargout = minres(varargin)
%MINRES   Minimum Residual Method for codistributed array.
%   X = MINRES(A,B)
%   X = MINRES(A,B)
%   X = MINRES(A,B,TOL)
%   X = MINRES(A,B,TOL,MAXIT)
%   X = MINRES(A,B,TOL,MAXIT,M)
%   X = MINRES(A,B,TOL,MAXIT,M1,M2)
%   X = MINRES(A,B,TOL,MAXIT,M1,M2,X0)
%   [X,FLAG] = MINRES(A,B,...)
%   [X,FLAG,RELRES] = MINRES(A,B,...)
%   [X,FLAG,RELRES,ITER] = MINRES(A,B,...)
%   [X,FLAG,RELRES,ITER,RESVEC] = MINRES(A,B,...)
%      
%   Note that B must be a non-sparse column vector.
%   
%   Example:
%   Using MINRES to solve a large system of codistributed array data:
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
%       x = MINRES(dA,db,tol,maxit)
%   end
%   
%   See also MINRES, CODISTRIBUTED.


%   Copyright 1984-2014 The MathWorks, Inc.

% Ensure that only the data inputs (args 1,2,5,6,7) are distributed
isData = [1 1 0 0 1 1 1];
varargin = distributedutil.CodistParser.prepareSolverInputs(varargin, isData);

% Call the local copy of the MATLAB code
[varargout{1:nargout}] = parallel.internal.flowthrough.minres(varargin{:});
