function Z = mod(X,Y)
%MOD Modulus after division of codistributed array
%   C = MOD(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = mod(codistributed.colon(1,N),2)
%   end
%   
%   See also MOD, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2014 The MathWorks, Inc.

Z = codistributed.pElementwiseOp(@mod, X, Y);
