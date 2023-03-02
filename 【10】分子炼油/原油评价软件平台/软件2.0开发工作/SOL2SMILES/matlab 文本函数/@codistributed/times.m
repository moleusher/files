function C = times(A,B)
%.* codistributed array multiply
%   C = A .* B
%   C = TIMES(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.eye(N);
%       D2 = codistributed.rand(N);
%       D3 = D1 .* D2
%   end
%   
%   See also TIMES, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@times,A,B);
