function C = bitor(A,B)
%BITOR Bit-wise OR of codistributed array
%   C = BITOR(A,B)
%   
%   The following syntaxes are not supported for codistributed array:
%   C = BITOR(A,B,ASSUMEDTYPE)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.ones(N,'uint32');
%       D2 = triu(D1);
%       D3 = bitor(D1,D2)
%   end
%   
%   See also BITOR, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@bitor,A,B);
