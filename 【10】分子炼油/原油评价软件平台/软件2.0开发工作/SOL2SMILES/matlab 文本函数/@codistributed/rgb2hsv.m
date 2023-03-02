function varargout = rgb2hsv(varargin)
%RGB2HSV Convert red-green-blue colors to hue-saturation-value.
%   H = RGB2HSV(M) converts an RGB color map to an HSV color map.
%   
%   HSV = RGB2HSV(RGB) converts the RGB image RGB (3-D array) to the
%   equivalent HSV image HSV (3-D array).
%   
%   Example:
%   spmd
%       rgb = codistributed.randi([0 255], 1024, 768, 3, 'uint8');
%       hsv = rgb2hsv(rgb)
%   end
%   
%   See also RGB2HSV, CODISTRIBUTED, CODISTRIBUTED/RANDI.


%   Copyright 1984-2014 The MathWorks, Inc.

[varargout{1:nargout}] = parallel.internal.flowthrough.rgb2hsv(varargin{:});
