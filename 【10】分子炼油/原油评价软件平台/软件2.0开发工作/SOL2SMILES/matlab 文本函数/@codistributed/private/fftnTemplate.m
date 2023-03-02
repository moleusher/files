function X = fftnTemplate(fftfcnstr, X, fftSize, sym)
%FFTNTEMPLATE Template for FFT2, FFTN, IFFT2, and IFFTN
%   Copyright 2014-2016 The MathWorks, Inc.

    fftSize = iCheckArg(fftSize);

    X = ensureFloatingPoint( X, 'MATLAB:fftfcn:InvalidInputType', ...
        {'int64', 'uint64'});
    
    codistr = getCodistributor(X);
    szX = size(X);

    % return early for an FFT of length 0
    if min(fftSize) == 0
        szX(1:numel(fftSize)) = fftSize; % Less than all for (I)FFT2 on an N-D array
        template = distributedutil.Allocator.extractTemplate(X);
        X = distributedutil.Allocator.createCodistributed(szX, template);
        return
    end

    localX = getLocalPart(X);
    isFFT = strncmpi(fftfcnstr, 'FFT', 3);
    if nargin < 4
        sym = 'nonsymmetric';
    end
    
    % if the implementation isn't available on codistr, redistribute to 1d
    if ~hFftnCheck(codistr, fftSize)
        oldCodistr = codistr;
        [~, newDistDim] = max(szX);
        codistr = codistributor1d(newDistDim, ...
                            codistributor1d.defaultPartition(szX(newDistDim)), ...
                            szX);
        localX = distributedutil.Redistributor.redistribute(oldCodistr, ...
                                                       localX, codistr);
    end

    [localX, codistr] = hFftnImpl(codistr, localX, fftSize, sym, isFFT);

    X = codistributed.pDoBuildFromLocalPart(localX, codistr); %#ok<DCUNK> private static
end

function n = iCheckArg(n)
    AllowZero = true;
    if ~(islogical(n) || isPositiveIntegerValuedNumeric(n, AllowZero))
        error(message('MATLAB:fftfcn:lengthNotNonNegInt'));
    end
end
