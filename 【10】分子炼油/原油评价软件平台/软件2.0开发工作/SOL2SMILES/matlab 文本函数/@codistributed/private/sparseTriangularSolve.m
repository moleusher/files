function [x, rCond] = sparseTriangularSolve(transposeFirstMatrix, A, B, DistA, matrixType)
% SPARSETRIANGULARSOLVE Triangular solver for codistributed sparse matrices
% Solver for A*x = B with strict upper/lower triangular matrix A.

%   Copyright 2016 The MathWorks, Inc.
    
    % If necessary, change distribution scheme of A  depending on desired operation
    if ~transposeFirstMatrix && ...
            (isa(DistA, 'codistributor2dbc') || ...
            (isa(DistA, 'codistributor1d') && DistA.Dimension==2))
        % Change to distribution by rows
        DistA = codistributor1d(1, ...
            codistributor1d.defaultPartition(size(A,1)), size(A));
        A = redistribute(A, DistA);
    elseif transposeFirstMatrix && ...
            (isa(DistA, 'codistributor2dbc') || ...
            (isa(DistA, 'codistributor1d') && DistA.Dimension==1))
        % Change to distribution by columns
        DistA = codistributor1d(2, ...
            codistributor1d.defaultPartition(size(A,1)), size(A));
        A = redistribute(A, DistA);
    end
    
    % New codistributor for B by rows with matching partition as A
    DistB = codistributor1d(1, DistA.Partition, size(B));
    % Check distribution scheme of B and redistribute if necessary
    [B, origDistB, redistributeSolution] = redistributeIfNeeded(B, DistB);
    
    % Check if forward or backward substitution is needed
    if (~transposeFirstMatrix && strncmpi(matrixType, 'LowerTriangular', 1)) || ...
            (transposeFirstMatrix && strncmpi(matrixType, 'UpperTriangular', 1))
        solveForward = true;
    else
        solveForward = false;
    end
    [x, rCond] = iBlockTriangularSubstitution(transposeFirstMatrix, ...
        solveForward, A, B, origDistB, redistributeSolution);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, rCond] = iBlockTriangularSubstitution(transposeFirstMatrix, ...
    solveForward, A, B, DistSolution, redistributeSolution)
% Block forward/backward substitution to solve lower or upper
% triangular system, respectively:
%                    [A11  0   0 ]   [x1]   [B1]
% A*x = B,  e.g.,    [A21 A22  0 ] * [x2] = [B2]
%                    [A31 A32 A33]   [x3]   [B3]
%
% Operating on local parts, perform multiplication in parallel as soon
% as data is available to update B.
%
% x1 = A11\B1;
% B2 = B2 - A21*x1; x2 = A22\B2;
% B3 = B3 - A31*x1; B3 = B3 - A32*x2; x3 = A33\B3;
    
    % Define unique tag
    iterappTag = 10000;
    % Get Codistributor
    DistA = getCodistributor(A);
    if redistributeSolution
        DistB = getCodistributor(B);
    else
        DistB = DistSolution;
    end
    % Get local parts
    localA = getLocalPart(A);
    localB = getLocalPart(B);
    isSparseB = issparse(localB);
    % Get local offset
    localOffset = globalIndices(DistA, DistA.Dimension);
    
    % Only perform work on workers with data
    if ~isempty(localOffset)
        localOffset = localOffset(1)-1;
    
        % Set up index of senders
        if solveForward
            index = 1:labindex-1;
        else
            index = numlabs:-1:labindex+1;
        end
        % Restrict senders to workers with data
        index = intersect(index, find(DistA.Partition));
        for i = index
            % Receive all already existing parts of the solution from workers with data
            xremote = labReceive(i, iterappTag+i);
            % Multiply related local parts with already known parts of solution
            indexAStart = sum(DistA.Partition(1:i-1))+1;
            indexAEnd = sum(DistA.Partition(1:i));
            if transposeFirstMatrix
                localB = localB-localA(indexAStart:indexAEnd, :)'*xremote;
            else
                localB = localB-localA(:, indexAStart:indexAEnd)*xremote;
            end
        end

        % Solve with local triangular part; turn off warning since we check
        % singularity later explicitly
        warning('off','MATLAB:singularMatrix');
        if transposeFirstMatrix
            localm = size(localA,2);
            localx = localA((1:localm) + localOffset, :)'\localB;
        else
            localm = size(localA,1);
            localx = localA(:, (1:localm) + localOffset)\localB;
        end
        % Switch on warning again
        warning('on','MATLAB:singularMatrix');
        
        % Set up index of receivers
        if solveForward
            index = labindex+1:numlabs;
        else
            index = labindex-1:-1:1;
        end
        % Restrict receivers to workers with data
        index = intersect(index, find(DistA.Partition));
        % Send existing part of solution to all other processes in index
        if ~isempty(index)
            labSend(localx, index, iterappTag+labindex);
        end
        % Reestablish sparsity of the result
        if isSparseB
        localx = sparse(localx);
        end
    else
        % Create localx of correct size and sparsity for workers with no data
        localx = zeros(0,size(localB,2),'like',localB);
    end
    
    % Reciprocal condition number calculation
    rCond = iCalculateConditionNumberTriang(localA, DistA);
    % Build solution as codistributed variable with desired distribution
    x = codistributed.pDoBuildFromLocalPart(localx, DistB); %#ok<DCUNK>
    % Redistribute solution if necessary
    if redistributeSolution
        x = redistribute(x, DistSolution);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rCond = iCalculateConditionNumberTriang(localA, DistA)
% Calculate condition number for triangular matrix
    diagIndLocalA = DistA.hFindDiagElementsInLocalPart();
    % Find max element, -min element, and if any NaNs exist along the diagonal
    if isempty(diagIndLocalA)
        % For an empty diagLocalA set values that do not influence the calculation
        localMaxMinNan = [0, -Inf, 0];
    else
        absLocalDiag = abs(localA(diagIndLocalA));
        localMaxMinNan = [max(absLocalDiag), -min(absLocalDiag), any(isnan(absLocalDiag))];
    end
    maxMinNan = gop(@max, localMaxMinNan);

    hasNans = maxMinNan(3);

    if hasNans
        rCond = NaN;
    else
        rCond = -maxMinNan(2)/maxMinNan(1);
    end
end
