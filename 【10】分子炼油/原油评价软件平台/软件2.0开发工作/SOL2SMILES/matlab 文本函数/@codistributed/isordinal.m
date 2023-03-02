function tf = isordinal(c)
%ISORDINAL True if the categories in a categorical array have a mathematical ordering.
%   
%   TF = ISORDINAL(C)
%    
%   See also ISORDINAL, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

tf = isordinal(getLocalPart(c));

