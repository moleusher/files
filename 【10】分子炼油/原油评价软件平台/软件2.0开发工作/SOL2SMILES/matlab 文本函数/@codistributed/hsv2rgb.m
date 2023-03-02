function varargout = hsv2rgb(varargin)
%HSV2RGB Convert hue-saturation-value colors to red-green-blue.
%   M = hsv2rgb(H) converts an HSV color map to an RGB color map.
%   
%   RGB = hsv2rgb(HSV) converts the HSV image HSV (3-D array) to the
%   equivalent RGB image RGB (3-D array).
%   
%   Example:
%   spmd
%       hsv = codistributed.rand(1024, 768, 3);
%       rgb = hsv2rgb(hsv)
%   end
%   
%   See also HSV2RGB, CODISTRIBUTED, CODISTRIBUTED/RANDI.


%   Copyright 1984-2014 The MathWorks, Inc.

[varargout{1:nargout}] = parallel.internal.flowthrough.hsv2rgb(varargin{:});
