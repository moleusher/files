function C = bitxor(A,B)
%BITXOR Bit-wise XOR of codistributed array
%   C = BITXOR(A,B)
%   
%   The following syntaxes are not supported for codistributed array:
%   C = BITXOR(A,B,ASSUMEDTYPE)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.ones(N,'uint32');
%       D2 = triu(D1);
%       D3 = bitxor(D1,D2)
%   end
%   
%   See also BITXOR, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@bitxor,A,B);
