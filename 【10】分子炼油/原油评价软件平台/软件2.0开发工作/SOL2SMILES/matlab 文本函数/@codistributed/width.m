function w = width(A)
%WIDTH Number of variables in a codistributed table.
%   W = WIDTH(T)
%   
%   See also WIDTH, CODISTRIBUTED.


%   Copyright 2016 The MathWorks, Inc.

if ~istable(A)
    error(message('parallel:array:UnsupportedFunction', upper(mfilename), classUnderlying(A)));
end
w = size(A,2);
