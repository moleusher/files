function C = le(A,B)
%<= Less than or equal for codistributed array
%   C = A <= B
%   C = LE(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       T = D <= D
%       F = D <= D-0.5
%   end
%   
%   returns T = codistributed.true(N)
%   and F = codistributed.false(N).
%   
%   See also LE, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@le,A,B);
