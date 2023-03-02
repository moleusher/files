function C = gt(A,B)
%> Greater than for codistributed array
%   C = A > B
%   C = GT(A,B)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       T = D > D-0.5
%       F = D > D
%   end
%   
%   returns T = codistributed.true(N) 
%   and F = codistributed.false(N).
%   
%   See also GT, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2014 The MathWorks, Inc.

C = codistributed.pElementwiseOp(@gt,A,B);
