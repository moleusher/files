function X = ifft(varargin)
%IFFT Inverse discrete Fourier transform of codistributed array
%   Y = IFFT(X) is the inverse discrete Fourier transform of 
%   codistributed array X.
%   
%   Y = IFFT(X,N) is the N-point inverse transform.
%    
%   Y = IFFT(X,[],DIM) or IFFT(X,N,DIM) is the inverse discrete Fourier
%   transform of X across the dimension DIM.
%    
%   Y = IFFT(..., 'symmetric') causes IFFT to treat X as conjugate symmetric along
%   the active dimension.  See the reference page for IFFT for the specific
%   mathematical definition of this symmetry. If your input array is conjugate
%   symmetric, then using the 'symmetric' parameter can speed up execution.
%    
%   Y = IFFT(..., 'nonsymmetric') causes IFFT to make no assumptions about the
%   symmetry of X.
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
%       Y = ifft(X);
%   end
%   
%   See also IFFT, CODISTRIBUTED.


%   Copyright 2006-2016 The MathWorks, Inc.
    narginchk(1, 4)

    distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);
    
    X = varargin{1};
    num_inputs = nargin;
    sym = 'nonsymmetric';
    if ischar(varargin{end})
        sym = varargin{end};
        num_inputs = num_inputs - 1;
        if ~any(strncmpi( sym, {'nonsymmetric', 'symmetric'}, ...
                max(1, strlength(sym)) ))
            error(message('MATLAB:fftfcn:InvalidTrailingStringArgument'))
        end
    end

    dim = distributedutil.Sizes.firstNonSingletonDimension(size(X));
    n = size(X, dim);
    switch num_inputs
        case 2
            n = distributedutil.CodistParser.gatherIfCodistributed(varargin{2});
            n = iCheckN(X, n, dim);
        case 3
            dim = distributedutil.CodistParser.gatherIfCodistributed(varargin{3});
            if ~isscalar(dim) || ~isPositiveIntegerValuedNumeric(dim)
                error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
            end
            n = distributedutil.CodistParser.gatherIfCodistributed(varargin{2});
            n = iCheckN(X, n, dim);
        case 4  % Last argument wasn't a string
            error(message('MATLAB:fftfcn:InvalidTrailingStringArgument'));
    end

    if ~isa(X, 'codistributed')
        X = ifft(X, n, dim, sym);
        return;
    end

    try
        X = fftTemplate(X, n, dim, sym);
    catch ME
        throw(ME);
    end

end

function n = iCheckN(X, n, dim)
    if isempty(n)
        n = size(X, dim);
    end
    AllowZero = true;
    if ~isscalar(n) || ~(islogical(n) || isPositiveIntegerValuedNumeric(n, AllowZero))
        error(message('MATLAB:fftfcn:lengthNotNonNegInt'));
    end
    % Make sure N is always a double to avoid influencing the type of
    % the output
    n = double(n);
    if floor(n) ~= n
        n = floor(n);
        warning(message('MATLAB:fftfcn:lengthNotNonNegInt'));
    end
end