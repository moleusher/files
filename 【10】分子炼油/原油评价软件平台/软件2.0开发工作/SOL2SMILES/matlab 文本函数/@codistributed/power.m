function Z = power(X,Y)
%.^ Array power for codistributed array
%   C = A .^ B
%   C = POWER(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = 2*codistributed.eye(N);
%       D2 = D1 .^ 2
%   end
%   
%   See also POWER, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2014 The MathWorks, Inc.

Z = codistributed.pElementwiseOp(@power,X,Y);
