function s = categories(a)
%CATEGORIES Get a list of a categorical array's categories.
%   S = CATEGORIES(A)
%   
%   See also: CATEGORIES, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

s = categories(getLocalPart(a));
