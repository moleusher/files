function h = height(A)
%HEIGHT Number of rows in a codistributed table.
%   H = HEIGHT(T)
%   
%   See also HEIGHT, CODISTRIBUTED.


%   Copyright 2016 The MathWorks, Inc.

if ~istable(A)
    error(message('parallel:array:UnsupportedFunction', upper(mfilename), classUnderlying(A)));
end
h = size(A,1);
