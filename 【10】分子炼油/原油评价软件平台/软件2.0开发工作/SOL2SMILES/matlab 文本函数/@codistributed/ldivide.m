function C = ldivide(A,B)
%.\ Left array divide for codistributed array matrix
%   C = A .\ B
%   C = LDIVIDE(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.colon(1, N)'
%       D2 = D1 .\ 1 
%   end
%   
%   See also LDIVIDE, CODISTRIBUTED, CODISTRIBUTED/COLON.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@ldivide,A,B);
