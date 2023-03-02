function F = full(S)
%FULL Convert sparse codistributed matrix to full codistributed matrix
%   F = FULL(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.speye(N);
%       F = full(D)
%   end
%   
%   returns F = codistributed.eye(N).
%   
%   t = issparse(D)
%   f = issparse(F)
%   
%   returns t = true and f = false.
%   
%   See also FULL, CODISTRIBUTED, CODISTRIBUTED/SPEYE.
%   


%   Copyright 2006-2014 The MathWorks, Inc.

F = codistributed.pElementwiseUnaryOp(@full,S);
