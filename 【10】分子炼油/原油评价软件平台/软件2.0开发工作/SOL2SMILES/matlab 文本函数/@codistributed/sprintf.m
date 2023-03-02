function varargout = sprintf(varargin) %#ok<STOUT>
%SPRINTF overloaded for codistributed arrays
%   SPRINTF is not supported for codistributed array inputs.
%   
%   See also SPRINTF, CODISTRIBUTED.
%   

%   Copyright 2010-2016 The MathWorks, Inc.

error(message('parallel:array:UnsupportedFunction', mfilename, 'codistributed'));
end
