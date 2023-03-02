function A = loadobj(A)
;%#ok

%LOADOBJ Overloaded for codistributed arrays
%   
%   See also LOADOBJ, CODISTRIBUTED.


%   Copyright 2008-2011 The MathWorks, Inc.

aDist = getCodistributor(A);
storedNumLabs = aDist.hNumLabs();
if storedNumLabs ~= numlabs
    warning(message('parallel:distributed:InvalidNumberOfLabs', storedNumLabs, numlabs));
end
