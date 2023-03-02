function Z = rem(X,Y)
%REM Remainder after division for codistributed array
%   C = REM(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = rem(codistributed.colon(1, N),2)
%   end
%   
%   See also REM, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2014 The MathWorks, Inc.

Z = codistributed.pElementwiseOp(@rem, X, Y);
