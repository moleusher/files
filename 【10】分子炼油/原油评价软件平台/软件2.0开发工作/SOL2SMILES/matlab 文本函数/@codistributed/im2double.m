function varargout = im2double(varargin)
%IM2DOUBLE Convert codistributed image to double precision.
%   IM2DOUBLE takes a codistributed image as input, and returns a codistributed image
%   of underlying class double.  If the input codistributed image is of class
%   double, the output codistributed image is identical to it.  If the input
%   codistributed image is not double, IM2DOUBLE returns the equivalent codistributed
%   image of underlying class double, rescaling or offsetting the data as
%   necessary.
%   
%   I2 = IM2DOUBLE(I1) converts the codistributed intensity image I1 to double
%   precision, rescaling the data if necessary.
%   
%   RGB2 = IM2DOUBLE(RGB1) converts the truecolor codistributed image RGB1 to
%   double precision, rescaling the data if necessary.
%   
%   I = IM2DOUBLE(BW) converts the binary codistributed image BW to a double-
%   precision intensity image.
%   
%   X2 = IM2DOUBLE(X1,'indexed') converts the indexed codistributed image X1 to
%   double precision, offsetting the data if necessary.
%   
%   Class Support
%   -------------
%   Intensity and truecolor codistributed images can be uint8, uint16, double,
%   logical, single, or int16. Indexed codistributed images can be uint8,
%   uint16, double or logical. Binary input codistributed images must be
%   logical. The output image is a codistributed with underlying class of double.
%   
%   Example
%   -------
%   spmd
%       I1 = codistributed(reshape(uint8(linspace(1,255,25)),[5 5]))
%       I2 = im2double(I1)
%   end
%   
%   See also IM2DOUBLE, codistributed.
%   
%   Copyright 2013-2014 The MathWorks, Inc.
%   


%   Copyright 2013-2014 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.im2double(varargin{:});
catch ME
    throw(ME);
end
