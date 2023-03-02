function X = fftTemplate(X, n, dim, sym)
%FFTTEMPLATE Template for FFT and IFFT
%   Copyright 2012-2016 The MathWorks, Inc.

    if nargin<4
        sym = 'fft';
        fcn = @(x, n, dim)fft(x, n, dim);
        isFFT = true;
    else
        fcn = @(x, n, dim)ifft(x, n, dim, sym);
        isFFT = false;
    end

    % Error for sparse input
    if issparse(X)
        error(message('MATLAB:fftfcn:SparseInputType'))
    end
    
    X = ensureFloatingPoint( X, 'MATLAB:fftfcn:InvalidInputType', ...
        {'int64', 'uint64'});
    
    codistr = getCodistributor(X);

    % Return early for an FFT of length 0
    if min(n, size(X, dim)) == 0
        sz = ones(1, max(ndims(X), dim));
        sz(1:ndims(X)) = size(X);
        sz(dim) = n;
        X = zeros(sz, codistr.hGetNewForSize(sz), 'like', X);
        return
    end

    % Return early when the fft dimension is a singleton
    if size(X, dim) == 1
        sz = ones(1, max(ndims(X), dim));
        sz(dim) = n;
        if isFFT
            X = repmat(X, sz);
        else
            scaleFactor = ones(1, 'like', X)/n;
            X = repmat(scaleFactor*X, sz);
        end
        return
    end

    localX = getLocalPart(X);

    % Determine whether we can use a truly parallel algorithm; otherwise, fall
    % through to the general case.  The downside of the general case is that
    % it can run out of memory for long FFTs.
    if isvector(X) && ~(isprime(n) || n == 1) && ~strcmpi(sym, 'symmetric')
        [localX, codistr] = iNonPrimeVectorFft(codistr, localX, n, dim, isreal(X), isFFT);
    else
        [localX, codistr] = iGeneralFft(codistr, localX, n, dim, fcn);
    end

    X = codistributed.pDoBuildFromLocalPart(localX, codistr); %#ok<DCUNK> private static
end

% This algorithm for computing the fft simply redistributes the data so that
% worker stores all the data it needs to perform the fft locally.
function [localX, codistr] = iGeneralFft(codistr, localX, n, dim, fcn)
    fftCodistr = iGetCodistrForGeneralFft(codistr, dim);
    localX = distributedutil.Redistributor.redistribute(codistr, localX, ...
                                                      fftCodistr);
    localX = fcn(localX, n, dim);
    szX = fftCodistr.Cached.GlobalSize;
    szX(dim) = n;
    codistr = fftCodistr.hGetNewForSize(szX);
end

% This function determines a distribution scheme so that each worker
% stores all of the data it needs to perform the fft operation.
function codistr = iGetCodistrForGeneralFft(codistr, dim)
    if isa(codistr, 'codistributor1d') && codistr.Dimension ~= dim
        % Each worker already has all the data it needs to perform the
        % fft, so the codistributor doesn't need to change.
        return;
    end

    szX = codistr.Cached.GlobalSize;

    % When computing a fft over the rows of an array, if the array uses a 1d
    % distribution scheme over columns then each worker's local part will
    % contain all the data it needs for the computation.  For all other fft
    % dimensions, we choose a 1d distribution scheme over dimension dim - 1.
    if dim == 1
        codistr = codistributor1d(2, ...
                                  codistributor1d.defaultPartition(szX(2)), szX);
    else
        codistr = codistributor1d(dim-1, ...
                                  codistributor1d.defaultPartition(szX(dim-1)), szX);
    end
end

% We use a different fft algorithm for a vector fft of non-prime length to
% avoid out-of-memory errors that can occur when using the general algorithm.
function [localX, codistr] = iNonPrimeVectorFft(codistr, localX, n, dim, isRealX, isFFT)
% Determine the size of the local part each worker should store for
% the input, output, and workspace.
    if isFFT
        [inNumel, outNumel, workNumel] = parallel.internal.codistextern.getFftLocalSize1D(localX, n);
    else
        [inNumel, outNumel, workNumel] = parallel.internal.codistextern.getIfftLocalSize1D(localX, n);
    end

    % We need to redistribute the input using a 1d distribution scheme
    % so that each worker has the number of input elements this algorithm
    % expects in order to perform an fft of length n.
    inputPartition = gcat(inNumel);

    szInput = codistr.Cached.GlobalSize;

    % A column vector should be distributed over rows, while a row vector
    % should be distributed over columns.
    if szInput(2) == 1
        distrDim = 1;
    else
        distrDim = 2;
    end

    szOutput = szInput;
    szOutput(dim) = n;

    % Create a 1d distribution scheme for a vector of length n using the
    % partition required by the fft algorithm.
    fftCodistr = codistributor1d(distrDim, inputPartition, szOutput);

    % We get a local part of the right size and type in which to store the
    % input data.
    targetLP = distributedutil.Allocator.create(fftCodistr.hLocalSize(), localX);

    % Redistribute the input vector into the prerequisite
    % distribution scheme for performing the fft.
    if szInput(dim) >= n
        % The input vector is longer than the fft output vector, so
        % redistribute the first n elements of the input vector
        % to be like fftCodistr and drop the remaining elements.

        % Create a "view" of the first n elements of the input vector
        % so we can redistribute:
        sRedist = distributedutil.codistributors.SubsetRedistributable(codistr, ...
                                                          [0, 0], szOutput, []);

        localX = distributedutil.Redistributor.redistributeInto(sRedist, localX, ...
                                                          fftCodistr, targetLP);
    else
        % The input vector is shorter than the fft vector, so redistribute the
        % input vector into the first szInput(dim) elements of the fft vector.
        % Let the remaining elements be 0.
        %
        % Create a "view" of how the input vector would map onto the first
        % szInput(dim) entries of fftCodistr:
        sRedist = distributedutil.codistributors.SubsetRedistributable(fftCodistr, ...
                                                          [0, 0], szInput, []);
        localX = distributedutil.Redistributor.redistributeInto(codistr, localX, ...
                                                          sRedist, targetLP);
    end

    % Perform the fft
    if isFFT
        localX = parallel.internal.codistextern.fft(localX, n, outNumel, ...
                                                    workNumel, isRealX);
    else
        localX = parallel.internal.codistextern.ifft(localX, n, outNumel, ...
                                                     workNumel, isRealX);
    end

    % Create the output codistributor
    codistr = codistributor1d(distrDim, gcat(outNumel), szOutput);
end
