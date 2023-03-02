function tf = issparse(A)
%ISSPARSE True for sparse codistributed matrix
%   TF = ISSPARSE(D)
%   Example:
%   
%   spmd
%       N = 1000;
%       D = codistributed.speye(N,N);
%       t = issparse(D)
%       f = issparse(full(D))
%   end
%   
%   returns t = true and f = false.
%   
%   See also ISSPARSE, CODISTRIBUTED, CODISTRIBUTED/SPEYE.


%   Copyright 2006-2014 The MathWorks, Inc.

aDist = getCodistributor(A);
localA = getLocalPart(A);

tf = aDist.hIssparseImpl(localA);
