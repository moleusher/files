function out = istable( obj )
%ISTABLE True for codistributed array of table.
%   TF = ISTABLE(T)
%   
%   See also ISTABLE, CODISTRIBUTED.
%   


%   Copyright 2016 The MathWorks, Inc.

out = isaUnderlying(obj, 'table');

end
