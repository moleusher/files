function X = fft(X, n, dim)
%FFT Discrete Fourier transform of codistributed array
%   Y = FFT(X) is the discrete Fourier transform (DFT) of vector X.  For 
%   matrices, the FFT operation is applied to each column.  For N-D arrays,
%   the FFT operation operates on the first non-singleton dimension.
%   
%   Y = FFT(X,M) is the M-point FFT, padded with zeros if X has less than
%   M points and truncated if it has more.
%   
%   Y = FFT(X,[],DIM) or Y = FFT(X,M,DIM) applies the FFT operation across 
%   the dimension DIM.
%   
%   Class support for input X: 
%     float: double, single 
%     integer: int8, uint8, int16, uint16, int32, uint32
%     logical
%   
%   Example:
%   spmd
%       Nrow = 2^16;
%       Ncol = 100;
%       X = codistributed.rand(Nrow, Ncol);
%       Y = fft(X);
%   end
%   
%   returns the FFT Y of the codistributed matrix by applying the FFT to 
%   each column.
%   
%   The current implementation gathers vectors on a single worker to perform
%   prime length ffts rather than using a parallel FFT algorithm.  It 
%   may result in out-of-memory errors for large prime length vector ffts.
%   See also FFT, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2016 The MathWorks, Inc.

    if nargin < 3
        dim = distributedutil.Sizes.firstNonSingletonDimension(size(X));
    else
        dim = distributedutil.CodistParser.gatherIfCodistributed(dim);
        if ~isscalar(dim) || ~isPositiveIntegerValuedNumeric(dim)
            error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
        end
    end

    if nargin < 2 || (nargin > 1 && isempty(n))
        n = size(X,dim);
    else
        n = distributedutil.CodistParser.gatherIfCodistributed(n);
        AllowZero = true;
        if islogical(n)
            n = double(n);
        end
        if ~isscalar(n) || ~isPositiveIntegerValuedNumeric(n, AllowZero)
            error(message('MATLAB:fftfcn:lengthNotNonNegInt'));
        end
        if floor(n) ~= n
            n = floor(n);
            warning(message('MATLAB:fftfcn:lengthNotNonNegInt'));
        end
    end

    distributedutil.CodistParser.verifyNonCodistributedInputs({X, n, dim});

    if ~isa(X, 'codistributed')
        X = fft(X, n, dim);
        return;
    end

    try
        X = fftTemplate(X, n, dim);
    catch ME
        throw(ME);
    end

end
