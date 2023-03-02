function X = ifftn(varargin)
%IFFTN N-dimensional inverse discrete Fourier Transform.
%   Y = IFFTN(X) returns the N-dimensional inverse discrete Fourier transform
%   of codistributed array X.  If X is a vector, the output will have
%   the same orientation.
%   
%   Y = IFFTN(X, SIZ) pads or crops X to size SIZ before performing 
%   the transform.
%   
%   IFFTN(..., 'symmetric') causes IFFTN to treat X as multidimensionally
%   conjugate symmetric so that the output is purely real. See the reference
%   page for IFFTN for the specific mathematical definition of this symmetry.
%   If your input array is conjugate symmetric, then using the 'symmetric' 
%   parameter can speed up execution.
%   
%   IFFTN(..., 'nonsymmetric') causes IFFTN to make no assumptions about the
%   symmetry of X.
%   
%   Class support for input X: 
%     float: double, single 
%     integer: int8, uint8, int16, uint16, int32, uint32
%     logical
%   
%   Example:
%   spmd
%       N = 64;
%       X = codistributed.rand(N, N, N);
%       Y = ifftn(X);
%   
%   See also IFFTN, CODISTRIBUTED.


%   Copyright 2011-2016 The MathWorks, Inc.

    narginchk(1, 3)

    distributedutil.CodistParser.verifyNonCodistributedInputs(varargin)

    X = varargin{1};
    num_inputs = numel(varargin);
    
    % Check for a trailing string argument (if more than one arg)
    sym = 'nonsymmetric';
    if num_inputs>1 && ischar(varargin{end})
        sym = varargin{end};
        num_inputs = num_inputs - 1;
        if ~any(strncmpi( sym, {'nonsymmetric', 'symmetric'}, ...
                max(1, strlength(sym)) ))
            error(message('MATLAB:fftfcn:InvalidTrailingStringArgument'))
        end
    end

    szX = size(X);
    switch num_inputs
        case 1
            siz = szX;
        case 2
            args = distributedutil.CodistParser.gatherElements(varargin(2));
            siz = args{1};
            if isempty(siz) 
                siz = szX;
            elseif numel(siz) < numel(szX)
                error(message('MATLAB:fftfcn:outputSizeLessThanNdimsElements'))
            end
        otherwise
            error(message('MATLAB:fftfcn:InvalidTrailingStringArgument'))
    end
    
    try
        if ~isa(X, 'codistributed')
            X = ifftn(X, siz, sym);
            return
        end
        X = fftnTemplate(mfilename, X, siz, sym);
    catch ME
        throw(ME);
    end

end
