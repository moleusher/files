function varargout = scalaQr(A, flag)
%SCALAQR   ScaLAPACK QR factorization

%   Copyright 2010-2016 The MathWorks, Inc.

    use1DForResult = isa(getCodistributor(A), 'codistributor1d');

    % Redistribute input according to the default 2dbc distribution scheme.
    if ~isa(getCodistributor(A), 'codistributor2dbc')
        A = redistribute(A, codistributor2dbc());
    end

    distA = getCodistributor(A);
    lbgrid = distA.LabGrid;
    localA = getLocalPart(A);

    % Set up the array descriptor required by ScaLAPACK
    descA = arraydescriptor(A);

    [mA, nA] = size(A);

    % Set flag for "economy" factorization
    if mA > nA
        wantEconQR = isnumeric(flag);
    else
        wantEconQR = false;
    end

    % Set flag for pivot output
    wantPivots = nargout == 3;

    if wantPivots
        [localQ, localA, localE] = parallel.internal.codistextern.denseQrWithPivoting(localA, ...
                                                          descA, lbgrid(1), lbgrid(2), ...
                                                          distA.Orientation, ...
                                                          wantEconQR, isreal(A));
        E = iGeneratePermVector(distA, localE);
        if strcmpi(flag, 'matrix')
            % E is by construction 1d codistributed
            E = full(sparse(E, 1:length(E), 1));
        end
    else
        [localQ, localA] = parallel.internal.codistextern.denseQr(localA, descA, ...
                                                          lbgrid(1), lbgrid(2), ...
                                                          distA.Orientation, ...
                                                          wantEconQR, isreal(A));
    end

    if wantEconQR  % economy factorization
        [Q, A] = iConstructFactorsFromLPs(localQ, distA, localA, nA);
    else
        [A, Q] = iConstructFactorsFromLPs(localA, distA, localQ, mA);
    end

    A = triu(A);  % Get the upper triangular factor

    if use1DForResult
        Q = redistribute(Q, codistributor1d());
        A = redistribute(A, codistributor1d());
    elseif wantPivots % Redistribute E to default 2dbc codistribution
        E = redistribute(E, codistributor2dbc());
    end

    varargout{1} = Q;
    varargout{2} = A;
    if wantPivots
        typeA = classUnderlying(A);
        varargout{3} = cast(E, typeA);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function [A, B] = iConstructFactorsFromLPs(localA, codistrA, localB, szB)
% First array reuses codistrA because it is the same size as the original
% input.  The second array will be a square array that has a codistributor
% with the properties of codistrA but global size szB x szB

    A = codistributed.pDoBuildFromLocalPart(localA, codistrA); %#ok<DCUNK>

    % New codistributor for square factor
    codistr = codistributor2dbc(codistrA.LabGrid, codistrA.BlockSize, ...
                                codistrA.Orientation, [szB szB]);

    % Dispose of any workspace remaining in the upper rows and columns
    localSz = codistr.hLocalSize();
    localB = localB(1:localSz(1), 1:localSz(2));
    B = codistributed.pDoBuildFromLocalPart(localB, codistr); %#ok<DCUNK>
end

function P = iGeneratePermVector(distA, localP)
%iGeneratePermVector Convert pivot output from ScaLAPACK to a MATLAB
%                   permutation vector
%   Inputs: distA - 2dbc codistributor of matrix that was factored
%           localP - local part of pivot vector
%   Output: P - the permutation vector
    localSizeA = distA.hLocalSize();
    globalSizeA = distA.Cached.GlobalSize;
    processRow = distA.hLabindexToProcessorRow(labindex);
    localP = double(localP(processRow == 1, 1:localSizeA(2)));
    codistr = codistributor2dbc(distA.LabGrid, distA.BlockSize,  ...
                                distA.Orientation, [1 globalSizeA(2)]);
    P = codistributed.pDoBuildFromLocalPart(localP, codistr); %#ok<DCUNK>
end
