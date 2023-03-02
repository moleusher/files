function varargout = rgb2gray(varargin)
%RGB2GRAY Convert RGB codistributed image or colormap to grayscale.
%   RGB2GRAY converts RGB codistributed images to grayscale by eliminating the
%   hue and saturation information while retaining the
%   luminance.
%   
%   I = RGB2GRAY(RGB) converts the truecolor codistributed image RGB to the
%   grayscale intensity image I.
%   
%   NEWMAP = RGB2GRAY(MAP) returns a grayscale colormap
%   equivalent to MAP.
%   
%   Class Support
%   -------------
%   If the input is an RGB codistributed image, it can be uint8, uint16, double,
%   or single. The output codistributed image I has the same class as the input
%   image. If the input is a colormap, the input and output colormaps are
%   both of class double.
%   
%   Example
%   -------
%   spmd
%   I = codistributed(imread('board.tif'));
%   J = rgb2gray(I);
%   end
%   figure, imshow(I), figure, imshow(J);
%   
%   spmd
%   [X,map] = codistributed(imread('trees.tif'));
%   gmap = rgb2gray(map);
%   end
%   figure, imshow(X,map), figure, imshow(X,gmap);
%   
%   See also RGB2GRAY, IMSHOW, CODISTRIBUTED.
%   
%   Copyright 2013-2014 The MathWorks, Inc.
%   


%   Copyright 2013-2014 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.rgb2gray(varargin{:});
catch ME
    throw(ME);
end
