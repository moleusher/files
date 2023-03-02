function [A, rCond] = scalaTriangularSolve(transposeFirstMatrix, A, B, matrixType)
% SCALATRIANGULARSOLVE  SCALAPACK Triangular solver

%   Copyright 2006-2016 The MathWorks, Inc.

    use1DForResult = iUse1DForResult(A, B);

    % Redistribute input according to the column-oriented 2dbc distribution scheme.
    if ~isa(getCodistributor(A), 'codistributor2dbc')
        A = redistribute(A, ...
                         codistributor2dbc(codistributor2dbc.defaultLabGrid, ...
                                           codistributor2dbc.defaultBlockSize, ...
                                           'col'));
    end

    distributedB = isa(B, 'codistributed');
    distA = getCodistributor(A);
    lbgrid = distA.LabGrid;

    % new codistributor for B
    newDistB = codistributor2dbc(lbgrid, distA.BlockSize, ...
                                 distA.Orientation, size(B));
    if ~distributedB
        B = codistributed.pConstructFromReplicated(B, newDistB); %#ok<DCUNK> Calling a private static method.
    else
        origDistB = getCodistributor(B);
        B = redistribute(B, newDistB);
    end

    % If inputs are of different types, convert the double one to single
    if isaUnderlying(A,'single') && isaUnderlying(B,'double')
        B = single(B);
    end

    if isaUnderlying(A,'double') && isaUnderlying(B,'single')
        A = single(A);
    end

    isrealA = isreal(A);
    isrealB = isreal(B);

    descA = arraydescriptor(A);
    descB = arraydescriptor(B);

    localA = getLocalPart(A);

    if ~isrealA && isreal(localA)
        localA = complex(localA);
    end
    localB = getLocalPart(B);
    if ~isrealB && isreal(localB)
        localB = complex(localB);
    end

    % Reciprocal condition number calculation
    rCond = iCalculateConditionNumber(localA, distA);

    localA = parallel.internal.codistextern.denseMldivideTriangular(localA, descA, ...
                                                      localB, descB, lbgrid(1), lbgrid(2), distA.Orientation, ...
                                                      transposeFirstMatrix, matrixType, isrealA, isrealB);

    A = codistributed.pDoBuildFromLocalPart(localA, newDistB); %#ok<DCUNK>

    if use1DForResult
        if ~distributedB || ~isa(origDistB, 'codistributor1d')
            A = redistribute(A, codistributor1d(1));
        else
            A = redistribute(A, origDistB);
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function use1DForResult = iUse1DForResult(A, B)
    uses1D = @(x) isa(x, 'codistributed') && ...
             isa(getCodistributor(x), 'codistributor1d');
    if uses1D(A) || uses1D(B)
        use1DForResult = true;
    else
        use1DForResult = false;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rCond = iCalculateConditionNumber(localA, distA)
    diagIndLocalA = distA.hFindDiagElementsInLocalPart();

    % find max element, -min element, and if any NaNs exist along the diagonal
    if isempty(diagIndLocalA)
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
