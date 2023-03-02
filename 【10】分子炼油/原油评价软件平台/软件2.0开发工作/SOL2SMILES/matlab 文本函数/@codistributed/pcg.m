function [x, flag, relres, iter, resvec] = pcg(varargin)
%PCG   Preconditioned Conjugate Gradients Method for codistributed array.
%   X = PCG(A,B)
%   X = PCG(A,B)
%   X = PCG(A,B,TOL)
%   X = PCG(A,B,TOL,MAXIT)
%   X = PCG(A,B,TOL,MAXIT,M)
%   X = PCG(A,B,TOL,MAXIT,M1,M2)
%   X = PCG(A,B,TOL,MAXIT,M1,M2,X0)
%   [X,FLAG] = PCG(A,B,...)
%   [X,FLAG,RELRES] = PCG(A,B,...)
%   [X,FLAG,RELRES,ITER] = PCG(A,B,...)
%   [X,FLAG,RELRES,ITER,RESVEC] = PCG(A,B,...)
%      
%   Limitations:
%   If M1 is a function it is applied independently to each row.
%   If M1 is a matrix it must be lower-triangular. 
%   If M2 is a matrix it must be upper-triangular.
%   
%   Example:
%   Using PCG to solve a large system of codistributed array data:
%   spmd
%       A = delsq(numgrid('S',100)); % A sparse SPD system
%       b = full(sum(A,2));
%       
%       dA = codistributed(A);
%       db = codistributed(b);
%       tol = 1e-6;
%       maxit = 500;
%       x = pcg(dA,db,tol,maxit);
%   end
%   
%   See also PCG, CODISTRIBUTED.


%   Copyright 1984-2016 The MathWorks, Inc.

    % Ensure that only the data inputs (args 1,2,5,6,7) are distributed
    isData = [1 1 0 0 1 1 1];
    varargin = distributedutil.CodistParser.prepareSolverInputs(varargin, isData);

    % Check for an acceptable number of input arguments
    if nargin < 2
        error(message('MATLAB:pcg:NotEnoughInputs'));
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
            parallel.internal.flowthrough.itermsg('pcg', tol, maxit, 0, flag, iter, NaN);
        end
        return
    end
    
    [A, b, M1, M2, x0] = iterSetupArgs(A, b, M1, M2, x0);
    workCodistrB = getCodistributor(b);
    b = getLocalPart(b);
    
    [x, flag, relres, iter, resvec] = hPcgImpl(workCodistrB, A, b, tol, maxit, M1, M2, x0);
    
    % only display a message if the output flag is not used
    if nargout < 2
        parallel.internal.flowthrough.itermsg('pcg', tol, maxit, length(resvec), flag, iter, relres);
    end

    % construct distributed result
    x = codistributed.pDoBuildFromLocalPart(x, workCodistrB); %#ok<DCUNK>
end
