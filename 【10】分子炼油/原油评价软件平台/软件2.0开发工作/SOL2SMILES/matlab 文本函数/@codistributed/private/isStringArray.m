function tf = isStringArray(s)
%ISSTRINGARRAY  check that the input is a string array or cellstr
    
%   Copyright 2016 The MathWorks, Inc.

if iscodistributed(s)
    s = getLocalPart(s);
end

tf = isstring(s) || iscellstr(s);
