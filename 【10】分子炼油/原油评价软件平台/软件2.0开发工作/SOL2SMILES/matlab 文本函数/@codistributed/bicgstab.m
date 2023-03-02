function varargout = bicgstab(varargin)
%BICGSTAB   BiConjugate Gradients Stabilized Method for codistributed array.
%   X = BICGSTAB(A,B)
%   X = BICGSTAB(A,B)
%   X = BICGSTAB(A,B,TOL)
%   X = BICGSTAB(A,B,TOL,MAXIT)
%   X = BICGSTAB(A,B,TOL,MAXIT,M)
%   X = BICGSTAB(A,B,TOL,MAXIT,M1,M2)
%   X = BICGSTAB(A,B,TOL,MAXIT,M1,M2,X0)
%   [X,FLAG] = BICGSTAB(A,B,...)
%   [X,FLAG,RELRES] = BICGSTAB(A,B,...)
%   [X,FLAG,RELRES,ITER] = BICGSTAB(A,B,...)
%   [X,FLAG,RELRES,ITER,RESVEC] = BICGSTAB(A,B,...)
%   
%   
%   Example:
%   Using BICGSTAB to solve a large system of codistributed array data:
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
%       x = BICGSTAB(dA,db,tol,maxit)
%   end
%   
%   See also BICGSTAB, CODISTRIBUTED.


%   Copyright 2014-2015 The MathWorks, Inc.

% Ensure that only the data inputs (args 1,2,5,6,7) are distributed
isData = [1 1 0 0 1 1 1];
varargin = distributedutil.CodistParser.prepareSolverInputs(varargin, isData);

% Call the local copy of the MATLAB code
[varargout{1:nargout}] = parallel.internal.flowthrough.bicgstab(varargin{:});
