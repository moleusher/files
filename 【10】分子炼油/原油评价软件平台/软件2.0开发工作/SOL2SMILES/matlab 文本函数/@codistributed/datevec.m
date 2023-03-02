function varargout = datevec(t)
%DATEVEC Convert datetimes to date vectors.
%   
%   DV = DATEVEC(T)
%   [Y,MO,D,H,MI,S] = DATEVEC(T)
%   
%   See also DATEVEC.
%   


%   Copyright 2016 The MathWorks, Inc.

% T must be a datetime
clz = classUnderlying(t);
if ~ismember(clz, {'datetime', 'duration', 'calendarDuration'})
    error(message('parallel:array:UnsupportedFunction', upper(mfilename), clz));
end
if ~iscolumn(t) && nargout<2
    t = colonize(t);
end

% Always capture six separate columns so that it is an elementwise
% calculation.
out = cell(1,6);
[out{:}] = codistributed.pElementwiseUnaryOp(@datevec, t);

% Now package the real output
if nargout < 2
    % Single out = matrix
    varargout = {cat(2, out{:})};
else
    % Multi-out, so copy corresponding elements
    varargout(1:nargout) = out(1:nargout);
end

