function B = sparseLuSolve(transposeFirstInput, A, B)
% SPARSELUSOLVE  Sparse LU solver

%   Copyright 2014-2016 The MathWorks, Inc.

    % If either input is single, throw
    if distributedutil.CodistParser.isa(A,'single') || ...
            distributedutil.CodistParser.isa(B,'single')
        if transposeFirstInput
            ME = MException(message('MATLAB:mrdivide:sparseSingleNotSupported'));
        else
            ME = MException(message('MATLAB:mldivide:sparseSingleNotSupported'));
        end
        throwAsCaller(ME);
    end
    
    if isempty(A)
        % No work to be done, return early.
        return;
    end
    
    % The sparseMldivideSquare builtin does not support the
    % 'transposeFirstInput' argument properly, so we have to transpose
    % manually in that case.
    if transposeFirstInput
        A = ctranspose(A);
    end
    
    distA = getCodistributor(A);

    % Redistribute input according to the 1d distribution scheme over rows.
    A = redistribute(A, codistributor1d(1, [], distA.Cached.GlobalSize));

    distributedB = isa(B, 'codistributed');
    distA = getCodistributor(A);

    % new codistributor for B (this only works since A is square)
    newDistB = codistributor1d(1, distA.Partition, size(B));
    
    if ~distributedB
        B = codistributed.pConstructFromReplicated(B, newDistB); %#ok<DCUNK> Calling a private static method.
    else
        B = redistribute(B, newDistB);
    end

    isrealA = isreal(A);
    isrealB = isreal(B);

    localA = getLocalPart(A);
    localB = getLocalPart(B);

    isSparseB = issparse(localB);
    % localB needs to be full for use within SuperLU
    if isSparseB
        try % Error must be thrown on all workers
            localB = distributedutil.syncOnError(@full, localB);
        catch
            ME = MException(message('parallel:distributed:SparseOutOfMemory'));
            throwAsCaller(ME);
        end
    end
    
    % transpose locally to achieve row-major memory 
    localA = transpose(localA);
    
    firstGlobalRow = cumsum([0 distA.Partition]);
    
    % try...catch block allows some errors to force the pool to go down
    try
        localB = parallel.internal.codistextern.sparseMldivideSquare( ...
            false, ... % First argument is unused transposeFirstInput
            numlabs, 1, size(A,1), size(A,2), ...
            firstGlobalRow(labindex), ...
            localA, localB, nnz(localA), ...
            isrealA, isrealB);
    catch ME
        if iIsRecoverable(ME.identifier)
            % 'Recoverable' means we can retain the pool
            throw(ME);
        else
            % Convert errors into warnings and then abort. Errors thrown by
            % SuperLU (as opposed to returned) leave the pool in a bad
            % state so the pool needs to go down. Converting to warnings
            % allows us to ensure a message is displayed.
            warning(ME.identifier, ME.message);
            drawnow;   % Attempts to ensure message is displayed
            mpigateway('abort');
        end
    end

    if isSparseB
        % the sparsity of the result should be the same as the
        % sparsity of the right hand side
        localB = sparse(localB);
    end
        
    B = codistributed.pDoBuildFromLocalPart(localB, newDistB); %#ok<DCUNK>
end

function tf = iIsRecoverable(msgID)
% Returns false for the errors that need to bring down the pool, which is
% in a bad state
tf = ~any( strcmp( msgID, { ...
    'parallel:distributed:SparseSolverMessageBufferOverflow', ...
    'parallel:distributed:SparseSolverError' } ) );
end
