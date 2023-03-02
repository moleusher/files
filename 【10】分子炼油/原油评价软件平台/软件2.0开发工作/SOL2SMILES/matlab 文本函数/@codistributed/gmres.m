function [x, flag, relres, iter, resvec] = gmres(varargin)
%GMRES   Generalized Minimum Residual Method for codistributed array.
%   X = GMRES(A,B)
%   X = GMRES(A,B,RESTART)
%   X = GMRES(A,B,RESTART,TOL)
%   X = GMRES(A,B,RESTART,TOL,MAXIT)
%   X = GMRES(A,B,RESTART,TOL,MAXIT,M)
%   X = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2)
%   X = GMRES(A,B,RESTART,TOL,MAXIT,M1,M2,X0)
%   [X,FLAG] = GMRES(A,B,...)
%   [X,FLAG,RELRES] = GMRES(A,B,...)
%   [X,FLAG,RELRES,ITER] = GMRES(A,B,...)
%   [X,FLAG,RELRES,ITER,RESVEC] = GMRES(A,B,...)
%   
%   If M1 is a function it is applied independently to each row.
%   If M1 is a matrix it must be lower-triangular. 
%   If M2 is a matrix it must be upper-triangular.
%   
%   Example:
%   Using GMRES to solve a large system of codistributed array data:
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
%       x = gmres(dA,db,10,tol,maxit)
%   end
%   
%   See also GMRES, CODISTRIBUTED.


%   Copyright 1984-2015 The MathWorks, Inc.

    % Ensure that only the data inputs (args 1,2,6,7,8) are distributed
    isData = [1 1 0 0 0 1 1 1];
    varargin = distributedutil.CodistParser.prepareSolverInputs(varargin, isData);

    % Check for an acceptable number of input arguments
    if nargin < 2
        error(message('MATLAB:gmres:NumInputs'));
    end
    [A, b, tol, maxit, M1, M2, x0, restart] = iterCheckArgs(varargin{:});

    % Check for all zero right hand side vector => all zero solution
    isBzero = (nnz(b) == 0);           % is rhs vector, b, all zeros
    if (isBzero)                       % if rhs vector is all zeros
        x = b;                         % then  solution is all zeros
        flag = 0;                      % a valid solution has been obtained
        relres = 0;                    % the relative residual is actually 0/0
        iter = [0 0];                      % no iterations need be performed
        resvec = 0;                    % resvec(1) = norm(b-A*x) = norm(0)
        if (nargout < 2)
            parallel.internal.flowthrough.itermsg('gmres', tol, maxit, 0, flag, iter, NaN);
        end
        return
    end
    
    [A, b, M1, M2, x0] = iterSetupArgs(A, b, M1, M2, x0, restart);
    workCodistrB = getCodistributor(b);
    b = getLocalPart(b);
    
    [x, flag, relres, iter, resvec] = hGmresImpl(workCodistrB, A, b, restart, tol, maxit, M1, M2, x0);
    
    % only display a message if the output flag is not used
    if nargout < 2
        if maxit == 1
            parallel.internal.flowthrough.itermsg(sprintf('gmres'), tol, maxit, length(resvec), flag, iter(2), relres);
        else
            outiter = floor(length(resvec)/restart) + 1;
            initer = length(resvec) - (outiter-1)*restart - 1;
            parallel.internal.flowthrough.itermsg(sprintf('gmres(%d)', restart), tol, maxit, [outiter initer], flag, iter, relres);
        end
    end

    % construct distributed result
    x = codistributed.pDoBuildFromLocalPart(x, workCodistrB); %#ok<DCUNK>
end