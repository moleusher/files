function X = fftn(X, siz)
%FFTN N-dimensional discrete Fourier Transform.
%   Y = FFTN(X) returns the N-dimensional discrete Fourier transform
%   of codistributed array X.  If X is a vector, the output will have
%   the same orientation.
%   
%   Y = FFTN(X, SIZ) pads or crops X to size SIZ before performing 
%   the transform.
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
%       Y = fftn(X);
%   
%   See also FFTN, CODISTRIBUTED.


%   Copyright 2011-2016 The MathWorks, Inc.

    szX = size(X);
    if nargin==1
        siz = szX;
    elseif isempty(siz) 
        siz = szX;
    end

    distributedutil.CodistParser.verifyNonCodistributedInputs({X, siz});
    arg = distributedutil.CodistParser.gatherElements({siz});
    siz = arg{1};
    if numel(siz) < numel(szX)
        error(message('MATLAB:fftfcn:outputSizeLessThanNdimsElements'))
    end

    try
        if ~isa(X, 'codistributed')
            X = fftn(X, siz);
            return
        end
        X = fftnTemplate(mfilename, X, siz);
    catch ME
        throw(ME);
    end
end
