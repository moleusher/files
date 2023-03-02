function len = length(A)
%LENGTH Length of codistributed vector
%   L = LENGTH(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.zeros(0,N,0);
%       l = length(D)
%   end
%   
%   returns l = 0.
%   
%   See also LENGTH, CODISTRIBUTED, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2016 The MathWorks, Inc.


% Table explicitly forbids access to LENGTH, and throws a specific error.
if isaUnderlying(A, 'table')
    error(message('MATLAB:table:UndefinedLengthFunction', mfilename, classUnderlying(A)));
end

s = size(A);
if any(s == 0)
   len = 0;
else
   len = max(s);
end
