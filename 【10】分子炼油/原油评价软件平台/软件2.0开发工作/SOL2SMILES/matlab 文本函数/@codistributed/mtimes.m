function C = mtimes(A, B)
%* Matrix multiply for codistributed array
%   C = A * B
%   C = MTIMES(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       A = codistributed.rand(N)
%       B = codistributed.rand(N)
%       C = A * B
%   end
%   
%   See also MTIMES, CODISTRIBUTED.


%   Copyright 2006-2016 The MathWorks, Inc.

narginchk(2, 2);

try 
    C = mtimesImpl(A, B);
catch ME
    throwAsCaller(ME);
end
end