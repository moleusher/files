function X = fft2(X, mrows, ncols)
%FFT2 Two-dimensional discrete Fourier Transform for codistributed array
%   Y = FFT2(X) returns the two-dimensional Fourier transform of 
%   codistributed array X. If X is a vector, the result will have the 
%   same orientation.
%   
%   Y = FFT2(X,MROWS,NCOLS) pads codistributed array X with zeros to size MROWS-by-NCOLS
%   before transforming.
%   
%   Class support for input X: 
%     float: double, single 
%     integer: int8, uint8, int16, uint16, int32, uint32
%     logical
%   
%   Example:
%   spmd
%       N = 512;
%       X = codistributed.rand(N);
%       Y = fft2(X);
%   end
%   
%   See also FFT2, CODISTRIBUTED.


%   Copyright 2006-2016 The MathWorks, Inc.

    szX = size(X);
    if nargin==1
        mrows = szX(1);
        ncols = szX(2);
    else
        if isempty(mrows) 
            mrows = szX(1);
        end
        if isempty(ncols)
            ncols = szX(2);
        end
    end

    distributedutil.CodistParser.verifyNonCodistributedInputs({X, mrows, ncols});
    args = distributedutil.CodistParser.gatherElements({mrows, ncols});
    mrows = args{1};
    ncols = args{2};
    if ~isscalar(mrows) || ~isscalar(ncols)
        error(message('MATLAB:fftfcn:lengthNotNonNegInt'))
    end

    try
        if ~isa(X, 'codistributed')
            X = fft2(X, mrows, ncols);
            return
        end
        X = fftnTemplate(mfilename, X, [mrows, ncols]);
    catch ME
        throw(ME);
    end
end
