function varargout = scalaGeneralizedEig(A, B, ~, isvec )
% SCALAGENERALIZEDEIG ScaLAPACK symmetric generalized eigensolver

%   Copyright 2012-2016 The MathWorks, Inc.

    nargoutchk(0, 3);

    % When there are no output arguments, the function should still return
    % the eigenvalues.
    numOutputs = max(1, nargout);

    % Redistribute input according to the column-oriented 2dbc distribution scheme.
    [A, B, origDist] = iRedistributeInput(A, B);

    % Unify type
    [A, B] = iUnifyType(A, B);

    % Unify complexity
    isrealMatrices = isreal(A) && isreal(B);

    localA = getLocalPart(A);
    if ~isrealMatrices && isreal(localA)
        localA = complex(localA);
    end

    localB = getLocalPart(B);
    if ~isrealMatrices && isreal(localB)
        localB = complex(localB);
    end

    % Check for NaNs and Infs
    if all(all(isfinite(localA))) == false || all(all(isfinite(localB))) == false
        ME = MException(message('parallel:distributed:EigMatrixWithNaNInf'));
        throwAsCaller(ME);
    end

    % Get inputs for wrapper calls
    descA = arraydescriptor(A);
    descB = arraydescriptor(B);

    distr = getCodistributor(A);
    lbgrid = distr.LabGrid;

    if numOutputs < 3
        [eigVals, isDecompSuccessful] = parallel.internal.codistextern.denseGeneralEigValsOnly(localA, ...
                                                          descA, localB, descB, lbgrid(1), lbgrid(2), ...
                                                          distr.Orientation, isrealMatrices);
        % The ScaLAPACK output is replicated but we want codistributed output.
        if isvec
            varargout{1} = codistributed.pConstructFromReplicated(eigVals, codistributor1d()); %#ok<DCUNK>
        else
            varargout{1} = codistributed.pConstructFromReplicated(diag(eigVals), origDist); %#ok<DCUNK>
        end
    else
        [eigVals, eigVecs, isDecompSuccessful] = parallel.internal.codistextern.denseGeneralEigValsAndVectors(localA, ...
                                                          descA, localB, descB, lbgrid(1), lbgrid(2), ...
                                                          distr.Orientation, isrealMatrices);
        varargout{1} = iDistributeOutput(eigVecs, distr, origDist);
        if isvec
            varargout{2} = codistributed.pConstructFromReplicated(eigVals, codistributor1d()); %#ok<DCUNK>
        else
            varargout{2} = codistributed.pConstructFromReplicated(diag(eigVals), origDist); %#ok<DCUNK>
        end
                                                          
    end
    varargout{numOutputs} = isDecompSuccessful;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A, B, origDist] = iRedistributeInput(A, B)
    if ~isa(A, 'codistributed')
        origDist = getCodistributor(B);
        if ~isa(origDist, 'codistributor2dbc')
            B = redistribute(B, codistributor2dbc());
        end
        distr = getCodistributor(B);
        A = codistributed.pConstructFromReplicated(A, distr); %#ok<DCUNK> Calling a private static method.
        return
    end
    origDist = getCodistributor(A);
    if ~isa(origDist, 'codistributor2dbc')
        A = redistribute(A, codistributor2dbc());
    end
    distr = getCodistributor(A);

    % Distribute B same as A
    if ~isa(B, 'codistributed')
        B = codistributed.pConstructFromReplicated(B, distr); %#ok<DCUNK> Calling a private static method.
    else
        B = redistribute(B, distr);
    end
end

function [A, B] = iUnifyType(A, B)
% If inputs are of different types, convert the double one to single
    if isaUnderlying(A, 'single') && isaUnderlying(B, 'double')
        B = single(B);
    end
    if isaUnderlying(B, 'single') && isaUnderlying(A, 'double')
        A = single(A);
    end
end

function eigV = iDistributeOutput(eigVecs, distr, origDistr)
    eigV = codistributed.pDoBuildFromLocalPart(eigVecs, distr); %#ok<DCUNK> Calling a private static method.
    eigV = redistribute(eigV, origDistr);
end
