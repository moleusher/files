function [A, b, M1, M2, x0] = iterSetupArgs(A, b, M1, M2, x0, restart)
%ITERSETUPARGS Redistribute data inputs so that b and x0 are distributed by
% rows, M1 and M2 are distributed by rows in the same way as x0 if they are
% matrices, and A is distributed by columns in the same way as b if it is a
% matrix.  Also provide distributed transposes of the matrix inputs and
% return local parts of all except b unless b and x0 are different sizes,
% in which case both b and x0 are returned distributed.
% If we're using the GMRES solver, the restart argument will be given and
% we need to assure that the partition used for distribution has at
% least restart elements on the first lab.
    
%   Copyright 2015-2016 The MathWorks, Inc.

    % Check preconditioner functions for validity before redistributing A
    % and b because deadlock can occur if a test fails on one worker while
    % another is still involved in redistribution - g1229052
    n = size(x0, 1);
    m = size(b, 1);
    isLsqr = (m ~= n);
    % If M1 is a function, make sure it works
    if ~strcmp(M1.type, 'matrix')
        distributedutil.iterapp('mldivide', M1.fun, M1.type, M1.fcnstr, ...
            zeros(size(x0)), [0 n], 'notransp');
        M1.tfun = M1.fun;
    end
    % If M2 is a function, make sure it works
    if ~strcmp(M2.type, 'matrix')
        distributedutil.iterapp('mldivide', M2.fun, M2.type, M2.fcnstr, ...
            zeros(size(x0)), [0 n], 'notransp');
        M2.tfun = M2.fun;
    end
    
    % redistribute A and b if necessary
    inCodistrB = getCodistributor(b);
    if isa(inCodistrB, 'codistributor1d') && inCodistrB.Dimension == 1
        newPartB = inCodistrB.Partition;
    else
        newPartB = codistributor1d.defaultPartition(length(b));
    end
    if isLsqr
        inCodistrX = getCodistributor(x0);
        if isa(inCodistrX, 'codistributor1d') && inCodistrX.Dimension == 1
            newPartX = inCodistrX.Partition;
        else
            newPartX = codistributor1d.defaultPartition(length(x0));
        end
    else
        newPartX = newPartB;
    end
    if strcmp(A.type, 'matrix')
        inCodistrA = getCodistributor(A.fun);
        if isa(inCodistrA, 'codistributor1d') && inCodistrA.Dimension == 1
            newPartB = inCodistrA.Partition;
        end
        if isa(inCodistrA, 'codistributor1d') && inCodistrA.Dimension == 2
            newPartX = inCodistrA.Partition;
        end
        if nargin > 5  && newPartX(1)<restart+1  % GMRES
            newPartX = iGmresPartition(size(A.fun, 1), restart);
        end
        workCodistrA = codistributor1d(2, newPartX, size(A.fun));
        if ~(isa(inCodistrA, 'codistributor1d') && inCodistrA.Dimension == 2 ...
                && ~any(inCodistrA.Partition - newPartX))
            A.fun = redistribute(A.fun, workCodistrA);
        end
        if ~isLsqr
            newPartB = newPartX;
        end
        workCodistrAtrans = codistributor1d(2, newPartB, size(A.fun'));
        A.tfun = redistribute(A.fun', workCodistrAtrans);
        A.fun = getLocalPart(A.fun);
        A.tfun = getLocalPart(A.tfun);
    elseif nargin > 5 && newPartX(1)<restart+1
         newPartX = iGmresPartition(length(b), restart);
         newPartB = newPartX;
    else
        A.tfun = A.fun;
    end
    if ~(isa(inCodistrB, 'codistributor1d') && inCodistrB.Dimension == 1 ...
            && ~any(inCodistrB.Partition - newPartB))
        workCodistrB = codistributor1d(1, newPartB, size(b));
        b = redistribute(b, workCodistrB);
    end
    workCodistrX = codistributor1d(1, newPartX, size(x0));
    x0 = redistribute(x0, workCodistrX);
    if ~isLsqr
        x0 = getLocalPart(x0);
    end
    
    % Check that M1, M2, if they are matrices, are lower, upper (resp)
    % triangular and error if not
    workCodistrM = codistributor1d(1, newPartX, [n n]);
    if strcmp(M1.type, 'matrix') && ~isempty(M1.fun)
        isLower = true;
        try
            M1 = iCheckPreconditionMatrix(M1, workCodistrM, isLower);
        catch ME
            throwAsCaller(ME);
        end
    else
        % Function preconditioner should be replicated
        M1 = gather(M1);
    end
    if strcmp(M2.type, 'matrix') && ~isempty(M2.fun)
        isLower = false;
        try
            M2 = iCheckPreconditionMatrix(M2, workCodistrM, isLower);
        catch ME
            throwAsCaller(ME);
        end
    else
        % Function preconditioner should be replicated
        M2 = gather(M2);
    end
end

function M = iCheckPreconditionMatrix(M, codistr, isLower)
% Distribute M by rows and check that the part we have is triangular.  Put 
% the local part of the lower triangular version in M.fun and the local
% part of the upper triangular version in M.tfun
    M.fun = codistributed(M.fun, codistr);
    localM = getLocalPart(M.fun);
    if isLower
        trifun = @istril;
    else
        trifun = @istriu;
    end
    globalM = zeros(size(M.fun), 'like', localM);
    globalM(globalIndices(codistr, 1), :) = localM;
    if ~trifun(globalM)
        error(message('parallel:distributed:SparseSolverNoPrecondition'));
    end
    M.tfun = redistribute(M.fun', codistr);
    if isLower
        M.fun = localM;
        M.tfun = getLocalPart(M.tfun);
    else
        M.fun = getLocalPart(M.tfun);
        M.tfun = localM;
    end
end

function newPart = iGmresPartition(lenX, restart)
% Create a new partition that has restart+1 elements on the first lab
    firstPart = min(lenX, restart+1);
    remaining = lenX - firstPart;
    newPart = zeros(1, numlabs);
    newPart(1) = firstPart;
    newPart(2:end) = floor(double(remaining)/(numlabs-1));
    newPart(2:(rem(remaining,(numlabs-1))+1)) = ceil(double(remaining)/(numlabs-1));
end
