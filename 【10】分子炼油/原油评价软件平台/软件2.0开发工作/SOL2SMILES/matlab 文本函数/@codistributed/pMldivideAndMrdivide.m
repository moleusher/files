function [A, isNearlySingular] = pMldivideAndMrdivide(transposeFirstMatrix, A, B)
%pMldivideAndMrdivide is a common implementation of mldivide and mrdivide
%   for (co)distributed matrices
%   


%   Copyright 2012-2016 The MathWorks, Inc.

isNearlySingular = false;
if isa(A, 'codistributed')
    iErrorForIncompatibleDimension(A, B, transposeFirstMatrix);
    
    if size(A, 1) == size(A, 2) % Square case
        % Check whether A has a special structure to use the most efficient solver
        aDist = getCodistributor(A);
        matrixType = aDist.hIsTriangularImpl(getLocalPart(A));
        
        if strcmp(matrixType, 'Diagonal') % Solver for diagonal matrix (sparse and dense)
            [A, rCond] = diagSolve(transposeFirstMatrix, A, B, aDist);
            isNearlySingular = isnan(rCond) || (rCond < eps(class(rCond)));
            return
        end
        
        if issparse(A) % Sparse methods
            % If input B is single, throw
            if distributedutil.CodistParser.isa(B,'single')
                if transposeFirstMatrix
                    ME = MException(message('MATLAB:mrdivide:sparseSingleNotSupported'));
                else
                    ME = MException(message('MATLAB:mldivide:sparseSingleNotSupported'));
                end
                throwAsCaller(ME);
            end
            if any(strncmpi(matrixType, {'LowerTriangular', 'UpperTriangular'}, 1))
                [A, rCond] = sparseTriangularSolve(transposeFirstMatrix, A, B, aDist, matrixType);
            elseif strcmp(matrixType, 'ZeroMatrix')  % Zero case with correct output for sparse
                A = B/0;
                rCond = NaN;
            else % General matrix
                A = sparseLuSolve(transposeFirstMatrix, A, B);
                rCond = 1;
                % Unfortunately we aren't able to calculate the
                % reciprocal condition number for a general matrix, so we
                % will simply assume that the problem is well-conditioned.
            end
        else % Dense methods
            isSparseB = issparse(B);
            % If A single and B sparse, throw
            if distributedutil.CodistParser.isa(A,'single') && isSparseB
                if transposeFirstMatrix
                    ME = MException(message('MATLAB:mrdivide:sparseSingleNotSupported'));
                else
                    ME = MException(message('MATLAB:mldivide:sparseSingleNotSupported'));
                end
                throwAsCaller(ME);
            end
            % Try to make B full for use within SCALAPACK
            if isSparseB
                try % Error must be thwon on all workers
                    B = distributedutil.syncOnError(@full, B);
                catch
                    ME = MException(message('parallel:distributed:SparseOutOfMemory'));
                    throwAsCaller(ME);
                end
            end
            % Use the most efficient solver
            if any(strncmpi(matrixType, {'LowerTriangular', 'UpperTriangular'}, 1))
                [A, rCond] = scalaTriangularSolve(transposeFirstMatrix, A, B, matrixType);
            elseif  strcmp(matrixType, 'ZeroMatrix') % Zero case with correct output for dense
                [A, rCond] = scalaTriangularSolve(transposeFirstMatrix, A, B, 'LowerTriangular');
            else % General matrix
                [A, rCond] = scalaLuSolve(transposeFirstMatrix, A, B);
            end
        end
        isNearlySingular = isnan(rCond) || (rCond < eps(class(rCond)));
    else  % Not square case
        iErrorForSparseInputs(A, B, transposeFirstMatrix);
        
        if transposeFirstMatrix
            A = scalaQrSolve(ctranspose(A), B);
        else
            A = scalaQrSolve(A, B);
        end
    end
else
    bDist = getCodistributor(B);
    if ~( isa(bDist, 'codistributor1d') && (bDist.Dimension == 2) )
        B = redistribute(B, codistributor('1d', 2, ...
            codistributor1d.defaultPartition(size(B, 2))));
        bDist = getCodistributor(B);
    end
    if transposeFirstMatrix
        A = ctranspose(A);
    end
    % Since A is not codistributed and B is distributed by columns, the
    % labs all have different linear systems to solve.  A new codistributor
    % will be needed if A is not square.  In any case, the results of the
    % divide operation will have the same column distribution as B, and
    % the number of rows will be the number of columns in the input A.
    aDist = codistributor('1d', 2, bDist.Partition, [size(A, 2) size(B, 2)]);
    localX = iSolveLocalSystem(A, getLocalPart(B), transposeFirstMatrix);
    A = codistributed.pDoBuildFromLocalPart(localX, aDist); %#ok<DCUNK>
end
end

function iErrorForSparseInputs(A, B, transposeFirstMatrix)
if (issparse(A) || issparse(B))
    if transposeFirstMatrix
        ME = MException(message('parallel:distributed:MrdivideSparseInput'));
    else
        ME = MException(message('parallel:distributed:MldivideSparseInput'));
    end
    throwAsCaller(ME);
end
end

function iErrorForIncompatibleDimension(A, B, transposeFirstMatrix)
if transposeFirstMatrix
    dimToCompare = 2;
else
    dimToCompare = 1;
end

if size(A, dimToCompare) ~= size(B, 1)
    ME = MException(message('MATLAB:dimagree'));
    throwAsCaller(ME);
end
end

function X = iSolveLocalSystem(A, B, throwMrdivideErrors)
% Solve A*X = B, but throw any MLDIVIDE errors as MRDIVIDE errors if needed
try
    X = A\B;
catch ME
    if throwMrdivideErrors
        % This string replacement technique works as long as all the error
        % IDs continue to use the same theme (identical in all respects
        % except for rdivide/ldivide). Otherwise this code should change to
        % a switch statement.
        newMessageID = strrep( ME.identifier, 'ldivide', 'rdivide' );
        error( message( newMessageID ) );
    else
        rethrow(ME);
    end
end
end
