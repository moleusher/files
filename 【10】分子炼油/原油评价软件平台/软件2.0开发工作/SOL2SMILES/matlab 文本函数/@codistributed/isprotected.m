function tf = isprotected(c)
%ISPROTECTED True if the categories in a categorical array are protected.
%   
%   TF = ISPROTECTED(C)
%    
%   See also ISPROTECTED, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

tf = isprotected(getLocalPart(c));

