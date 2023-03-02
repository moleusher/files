function C = eq(A,B)
%== Equal for codistributed array
%   C = A == B
%   C = EQ(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       T = D == D
%       F = D == D'
%   end
%   
%   returns T = codistributed.true(N) and F is probably the same as
%   logical(codistributed.eye(N)).
%   
%   See also EQ, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@eq,A,B);
