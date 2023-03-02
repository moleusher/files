function C = bitand(A,B)
%BITAND Bit-wise AND of codistributed array
%   C = BITAND(A,B)
%   
%   The following syntaxes are not supported for codistributed array:
%   C = BITAND(A,B,ASSUMEDTYPE)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.ones(N,'uint32');
%       D2 = triu(D1);
%       D3 = bitand(D1,D2)
%   end
%   
%   See also BITAND, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@bitand,A,B);
