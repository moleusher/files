function C = minus(A,B)
%- Minus for codistributed array
%   C = A - B
%   C = MINUS(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.ones(N);
%       D2 = 2*D1
%       D3 = D1 - D2
%   end
%   
%   See also MINUS, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@minus,A,B);
