function C = rdivide(A,B)
%./ Right array divide for codistributed matrix
%   C = A ./ B
%   C = RDIVIDE(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.colon(1, N)'
%       D2 = 1 ./ D1
%   end
%   
%   See also RDIVIDE, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@rdivide,A,B);
