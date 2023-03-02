function Y = not(X)
%~ Logical NOT for codistributed array
%   B = ~A
%   B = NOT(A)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.eye(N);
%       E = ~D
%   end
%   
%   See also NOT, CODISTRIBUTED, CODISTRIBUTED/EYE.
%   


%   Copyright 2006-2011 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@not,X);
