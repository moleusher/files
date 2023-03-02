function [x, flag, relres, iter, resvec] = qmr(varargin)
%QMR   Quasi-Minimal Residual Method for codistributed array.
%   X = QMR(A,B)
%   X = QMR(A,B)
%   X = QMR(A,B,TOL)
%   X = QMR(A,B,TOL,MAXIT)
%   X = QMR(A,B,TOL,MAXIT,M)
%   X = QMR(A,B,TOL,MAXIT,M1,M2)
%   X = QMR(A,B,TOL,MAXIT,M1,M2,X0)
%   [X,FLAG] = QMR(A,B,...)
%   [X,FLAG,RELRES] = QMR(A,B,...)
%   [X,FLAG,RELRES,ITER] = QMR(A,B,...)
%   [X,FLAG,RELRES,ITER,RESVEC] = QMR(A,B,...)
%      
%   Note that B must be a non-sparse column vector.
%   
%   If M1 is a function it is applied independently to each row.
%   If M1 is a matrix it must be lower-triangular. 
%   If M2 is a matrix it must be upper-triangular.
%   
%   Example:
%   Using QMR to solve a large system of codistributed array data:
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
%       x = QMR(dA,db,tol,maxit)
%   end
%   
%   See also QMR, CODISTRIBUTED.


%   Copyright 1984-2016 The MathWorks, Inc.

% Ensure that only the data inputs (args 1,2,5,6,7) are distributed
isData = [1 1 0 0 1 1 1];
varargin = distributedutil.CodistParser.prepareSolverInputs(varargin, isData);

% Check for an acceptable number of input arguments
if nargin < 2
    error(message('MATLAB:qmr:NotEnoughInputs'));
end
[A, b, tol, maxit, M1, M2, x0] = iterCheckArgs(varargin{:});

% Check for all zero right hand side vector => all zero solution
isBzero = (nnz(b) == 0);           % is rhs vector, b, all zeros
if (isBzero)                       % if rhs vector is all zeros
    x = b;                         % then  solution is all zeros
    flag = 0;                      % a valid solution has been obtained
    relres = 0;                    % the relative residual is actually 0/0
    iter = 0;                      % no iterations need be performed
    resvec = 0;                    % resvec(1) = norm(b-A*x) = norm(0)
    if (nargout < 2)
        parallel.internal.flowthrough.itermsg('qmr', tol, maxit, 0, flag, iter, NaN);
    end
    return
end

[A, b, M1, M2, x0] = iterSetupArgs(A, b, M1, M2, x0);
workCodistrB = getCodistributor(b);
b = getLocalPart(b);

[x, flag, relres, iter, resvec] = hQmrImpl(workCodistrB, A, b, tol, maxit, M1, M2, x0);

% only display a message if the output flag is not used
if nargout < 2
    parallel.internal.flowthrough.itermsg('qmr', tol, maxit, length(resvec), flag, iter, relres);
end

% construct distributed result
x = codistributed.pDoBuildFromLocalPart(x, workCodistrB); %#ok<DCUNK>
end
