function[A, b, tol, maxit, m1, m2, x, restart] = iterCheckArgs(varargin)
%ITERCHECKARGS Extract arguments from argument list
%   Obtain input arguments for sparse iterative solvers and provide default
%   values as necessary
    
%   Copyright 2015-2016 The MathWorks, Inc.

    stack = dbstack;
    caller = stack(2).name;
    
    % Determine whether A is a matrix or a function.
    A = varargin{1};
    b = varargin{2};
    [A, m, n, nKnown] = iCheckA(caller, A, b);

    % Assign default values to unspecified parameters
    
    [tol, netargin, restart, restarted, varargin] = iGetArg3(caller, m, varargin{:});
    
    [maxit, restart] = iGetArg4(caller, m, restart, restarted, netargin, varargin{:});
    
    [m1, m2, n, nKnown] = iGetM(caller, n, nKnown, netargin, varargin{:});

    if (netargin < 7 || isempty(varargin{7}))
        if nKnown
            x = zeros([n,1], codistributor1d(1));
        else
            x = distributedutil.iterapp('mtimes', A.fun, A.type, A.fcnstr,...
                zeros(size(b)), [0 m], 'transp');
            x = codistributed(x);
        end
    else
        x = varargin{7};
        if ~nKnown
            n = size(x, 1);
        end
        if ~iscolumn(x) || size(x, 1) ~= n
            msgname = iGetMessageForSolver(caller, 'WrongInitGuessSize');
            error(message(['MATLAB:', caller, msgname], n));
        end
    end

    if ((netargin > 7) && strcmp(A.type,'matrix') && ...
            strcmp(m1.type,'matrix') && strcmp(m2.type,'matrix'))
        error(message(['MATLAB:', caller, ':TooManyInputs']));
    end
end

function [a, m, n, nKnown] = iCheckA(caller, A, b)
% Determine whether A is a matrix or a function and find its size
nKnown = false;
n = 0;
isLsqr = strcmpi(caller, 'lsqr');
[a.type, a.fun, a.fcnstr] = parallel.internal.flowthrough.iterchk(A);
if isLsqr && ~iscolumn(b)
    msgname = iGetMessageForSolver(caller, 'RSHnotColumn');
    error(message(['MATLAB:', caller, msgname]));
end

if strcmp(a.type,'matrix')
    % Check matrix and right hand side vector inputs have appropriate sizes
    [m, n] = size(a.fun);
    if (m ~= n && ~isLsqr)  % LSQR is only non-square solver
        msgname = iGetMessageForSolver(caller, 'NonSquareMatrix');
        error(message(['MATLAB:', caller, msgname]));
    else
        nKnown = true;
    end
    if ~isequal(size(b),[m,1])
        msgname = iGetMessageForSolver(caller, 'RSHsizeMatchCoeffMatrix');
        error(message(['MATLAB:', caller, msgname], m));
    end
else
    m = size(b, 1);
    if ~iscolumn(b)
        msgname = iGetMessageForSolver(caller, 'RSHnotColumn');
        error(message(['MATLAB:', caller, msgname]));
    end
end
end

function [tol, netargin, restart, restarted, varargout] = iGetArg3(caller, m, varargin)
% get tol (and if gmres) restart
if strcmpi(caller, 'gmres')
    if (nargin >=5)
        restart = varargin{3};
        varargin(3) = [];
        netargin = nargin-3;
    else
        netargin = nargin-2;
        restart = [];
    end
    restarted = ~(isempty(restart) || (restart == m));
else
    netargin = nargin-2;
    restart = [];
    restarted = false;
end
varargout = {varargin};

if netargin < 3 || isempty(varargin{3})
    tol = 1d-6;
else
    tol = varargin{3};
    if tol < eps
        warning(message(['MATLAB:', caller, ':tooSmallTolerance']));
        tol = eps;
    elseif tol >= 1
        warning(message(['MATLAB:', caller, ':tooBigTolerance']));
        tol = 1-eps;
    end
end
end

function [maxit, restart] = iGetArg4(caller, m, restart, restarted, netargin, varargin)
% Get maxit and adjust restart for gmres if necessary
if netargin < 4 || isempty(varargin{4})
    switch caller
        case 'gmres'
            if restarted
                maxit = min(ceil(m/restart), 10);
            else
                maxit = min(m, 10);
            end
        otherwise
            maxit = min(m, 20);
    end
else
    maxit = varargin{4};
end

if strcmpi(caller, 'gmres')
    if restarted
        if restart > m
            warning(message('MATLAB:gmres:tooManyInnerItsRestart', restart, m));
            restart = m;
        end
    else
        if maxit > m
            warning(message('MATLAB:gmres:tooManyInnerItsMaxit', maxit, m));
            maxit = m;
        end
        restart = maxit;
        maxit = 1;
    end
end
end

function [m1, m2, n, nKnown] = iGetM(caller, n, nKnown, netargin, varargin)
% Get preconditioners
if netargin < 5 || isempty(varargin{5})
    m1.type = 'matrix';
    m1.fun = [];
    m1.fcnstr = '';
else
    [m1.type, m1.fun, m1.fcnstr] = parallel.internal.flowthrough.iterchk(varargin{5});
    if strcmp(m1.type, 'matrix')
        if ~nKnown
            n = size(m1.fun, 1);
            nKnown = true;
        end
        if ~isequal(size(m1.fun), [n, n])
            msgname = iGetMessageForSolver(caller, 'WrongPrecondSize');
            error(message(['MATLAB:', caller, msgname], n));
        end
        m1.fcnstr = 'exists';
    end
end

if netargin < 6 || isempty(varargin{6})
    m2.type = 'matrix';
    m2.fun = [];
    m2.fcnstr = '';
else
    [m2.type, m2.fun, m2.fcnstr] = parallel.internal.flowthrough.iterchk(varargin{6});
    if strcmp(m2.type, 'matrix')
        if ~nKnown
            n = size(m2.fun, 1);
            nKnown = true;
        end
        if ~isequal(size(m2.fun), [n, n])
            msgname = iGetMessageForSolver(caller, 'WrongPrecond2Size');
            error(message(['MATLAB:', caller, msgname], n));
        end
        m2.fcnstr = 'exists';
    end
end
end

function msgname = iGetMessageForSolver(caller, msgID)
switch msgID
    case 'NonSquareMatrix'
        switch caller
            case 'gmres'
                msgname = ':SquareMatrix';
            otherwise
                msgname = [':' msgID];
        end
    case 'RSHsizeMatchCoeffMatrix'
        switch caller
            case 'bicg'
                msgname = ':RSHsizeMismatchCoeffMatrix';
            case 'gmres'
                msgname = ':VectorSize';
            otherwise
                msgname = [':' msgID];
        end
    case 'RSHnotColumn'
        switch caller
            case 'gmres'
                msgname = ':Vector';
            otherwise
                msgname = [':' msgID];
        end
    case 'WrongPrecondSize'
        switch caller
            case 'gmres'
                msgname = ':PreConditioner1Size';
            otherwise
                msgname = [':' msgID];
        end
    case 'WrongPrecond2Size'
        switch caller
            case 'gmres'
                msgname = ':PreConditioner2Size';
            otherwise
                msgname = ':WrongPrecondSize';
        end
    case 'WrongInitGuessSize'
        switch caller
            case 'gmres'
                msgname = ':XoSize';
            otherwise
                msgname = [':' msgID];
        end
end
end
