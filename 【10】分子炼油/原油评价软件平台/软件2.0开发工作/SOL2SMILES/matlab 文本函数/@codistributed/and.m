function Z = and(X,Y)
%& Logical AND for codistributed array
%   C = A & B
%   C = AND(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.eye(N);
%       D2 = codistributed.rand(N);
%       D3 = D1 & D2
%   end
%   
%   returns D3 a N-by-N codistributed logical array with the
%   diagonal populated with true values.
%   
%   See also AND, CODISTRIBUTED, CODISTRIBUTED/EYE.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

Z = codistributed.pElementwiseOp(@and,X,Y);
