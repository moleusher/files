function X = ifft2(varargin)
%IFFT2 Two-dimensional inverse discrete Fourier transform.
%   Y = IFFT2(X) returns the two-dimensional inverse Fourier transform of 
%   codistributed array X. If X is a vector, the result will have the 
%   same orientation.
%   
%   Y = IFFT2(X,MROWS,NCOLS) pads codistributed array X with zeros to size MROWS-by-NCOLS
%   before transforming.
%    
%   Y = IFFT2(..., 'symmetric') causes IFFT2 to treat X as conjugate symmetric in
%   two dimensions so that the output is purely real.  See the reference page
%   for IFFT2 for the specific mathematical definition of this symmetry. If 
%   your input array is conjugate symmetric, then using the 'symmetric' 
%   parameter can speed up execution.
%    
%   Y = IFFT2(..., 'nonsymmetric') causes IFFT2 to make no assumptions about the
%   symmetry of X.
%   
%   Class support for input X: 
%     float: double, single 
%     integer: int8, uint8, int16, uint16, int32, uint32
%     logical
%   
%   
%   Example:
%   spmd
%       N = 512;
%       X = codistributed.rand(N);
%       Y = ifft2(X);
%   end
%   
%   See also IFFT2, CODISTRIBUTED.


%   Copyright 2006-2016 The MathWorks, Inc.

    narginchk(1, 4)

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
            mrows = szX(1);
            ncols = szX(2);
        case 2
            error(message('MATLAB:ifft2:invalidSyntax'))
        case 3
            args = distributedutil.CodistParser.gatherElements(varargin(2:3));
            mrows = args{1};
            ncols = args{2};
            if isempty(mrows) 
                mrows = szX(1);
            end
            if isempty(ncols)
                ncols = szX(2);
            end
            if ~isscalar(mrows) || ~isscalar(ncols)
                error(message('MATLAB:fftfcn:lengthNotNonNegInt'))
            end
        otherwise
            error(message('MATLAB:fftfcn:InvalidTrailingStringArgument'))
    end
    
    try
        if ~isa(X, 'codistributed')
            X = ifft2(X, mrows, ncols, sym);
            return
        end
        X = fftnTemplate(mfilename, X, [mrows, ncols], sym);
    catch ME
        throw(ME);
    end

end
