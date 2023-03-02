function modstr = replace(origstr,oldstr,newstr)
%REPLACE Replace string with another.
%   
%   MODIFIEDSTR = REPLACE(ORIGSTR,OLDSUBSTR,NEWSUBSTR) 
%   
%   See also REPLACE.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(3,3);

% Inputs must be scalar or matching sizes. char vectors should be treated
% as scalar, so wrap in string.
if ischar(oldstr)
    oldstr = string(oldstr);
end
if ischar(newstr)
    newstr = string(newstr);
end

modstr = codistributed.pElementwiseOp(@replace, origstr, oldstr, newstr);