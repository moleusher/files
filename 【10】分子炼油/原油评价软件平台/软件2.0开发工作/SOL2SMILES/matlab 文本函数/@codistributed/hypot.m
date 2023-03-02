function C = hypot(A,B)
%HYPOT Robust computation of square root of sum of squares for codistributed array
%   C = HYPOT(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = 3e300*codistributed.ones(N);
%       D2 = 4e300*codistributed.ones(N);
%       E = hypot(D1,D2)
%   end
%   
%   See also HYPOT, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@hypot, A, B);
