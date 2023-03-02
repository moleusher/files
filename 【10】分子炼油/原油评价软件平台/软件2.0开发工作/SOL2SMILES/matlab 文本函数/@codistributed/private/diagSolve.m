function [x, rCond] = diagSolve(transposeFirstMatrix, A, B, DistA)
% DIAGSOLVE Diagonal solver for codistributed matrices
% Solver for systems A*x = B with a strict diagonal matrix A.

%   Copyright 2016 The MathWorks, Inc.
isSparseA = issparse(A);
if isSparseA
    % If input B is single, throw
    if distributedutil.CodistParser.isa(B,'single')
        if transposeFirstMatrix
            ME = MException(message('MATLAB:mrdivide:sparseSingleNotSupported'));
        else
            ME = MException(message('MATLAB:mldivide:sparseSingleNotSupported'));
        end
        throwAsCaller(ME);
    end
else
    % If input A is single and B is sparse, throw
    if distributedutil.CodistParser.isa(A,'single') && issparse(B)
        if transposeFirstMatrix
            ME = MException(message('MATLAB:mrdivide:sparseSingleNotSupported'));
        else
            ME = MException(message('MATLAB:mldivide:sparseSingleNotSupported'));
        end
        throwAsCaller(ME);
    end
end
% Redistribute A if necessary
if isa(DistA, 'codistributor2dbc')
    % Change to distribution by rows
    DistA = codistributor1d(1, codistributor1d.defaultPartition(size(A,1)), ...
        size(A));
    A = redistribute(A, DistA);
end
% New codistributor for B by rows with matching partition as A
DistB = codistributor1d(1, DistA.Partition, size(B));

[B, origDistB, redistributeSolution] = redistributeIfNeeded(B, DistB);

% Get local parts
localA = getLocalPart(A);
localB = getLocalPart(B);
% Get local diag offset
localOffset = globalIndices(DistA, DistA.Dimension);
% Perform operations only on worker with data
if ~isempty(localOffset)
    % Extract diagonal
    if sum(size(localA)==1)==1 % localA is 1-dimensional
        localDiagA = localA(localOffset(1));
    else
        % Get offset for diagonal
        if DistA.Dimension==1
            DiagOffset = localOffset(1)-1;
        else
            DiagOffset = -(localOffset(1)-1);
        end
        
        localDiagA = diag(localA, DiagOffset);
    end
    % Perform operation on local data element-wise
    if transposeFirstMatrix
        localx = localB./conj(localDiagA);
    else
        localx = localB./localDiagA;
    end
else % Worker with no data still need local data with right size
    localDiagA = zeros(0,1);
    % Ensure localx has same sparsity on all workers (depends on localB)
    localx = zeros(0,size(localB,2),'like',localB);
end

% Ensure solution is dense if localB is sparse (hence, localx is sparse) but A is dense
if issparse(localx) && ~isSparseA
    try % Error must be thrown on all workers
        localx = distributedutil.syncOnError(@full, localx);
    catch
        ME = MException(message('parallel:distributed:SparseOutOfMemory'));
        throwAsCaller(ME);
    end
end

% Reciprocal condition number calculation
rCond = iCalculateConditionNumberDiag(localDiagA);

% Build solution as codistributed variable with desired distribution
x = codistributed.pDoBuildFromLocalPart(localx, DistB); %#ok<DCUNK>

% Redistribute solution if necessary
if redistributeSolution
    x = redistribute(x, origDistB);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rCond = iCalculateConditionNumberDiag(localDiagA)
% Calculate condition number for diagonal matrix

% Find max element, -min element, and if any NaNs exist along the diagonal
if ~isempty(localDiagA)
    absLocalDiag = abs(localDiagA);
    localMaxMinNan = [max(absLocalDiag), -min(absLocalDiag), any(isnan(absLocalDiag))];
else
    % For an empty localDiagA set values that do not influence the calculation
    localMaxMinNan = [0, -Inf, 0];
end
% Collect max from all workers
maxMinNan = gop(@max, localMaxMinNan);
hasNans = maxMinNan(3);

if hasNans
    rCond = NaN;
else
    rCond = -maxMinNan(2)/maxMinNan(1);
end
end