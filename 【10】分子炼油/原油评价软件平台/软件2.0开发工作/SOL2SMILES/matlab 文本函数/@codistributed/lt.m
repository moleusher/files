function C = lt(A,B)
%< Less than for codistributed array
%   C = A < B
%   C = LT(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       T = D < D+0.5
%       F = D < D
%   end
%   
%   returns T = codistributed.true(N)
%   and F = codistributed.false(N).
%   
%   See also LT, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@lt,A,B);
