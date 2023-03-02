function numNz = nnz(A)
%NNZ Number of nonzero codistributed matrix elements
%   N = NNZ(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.speye(N);
%       n = nnz(D)  % n = N
%   end
%   
%   See also NNZ, CODISTRIBUTED, CODISTRIBUTED/SPEYE.


%   Copyright 2006-2012 The MathWorks, Inc.

aDist = getCodistributor(A);
localA = getLocalPart(A);

numNz = aDist.hNnzImpl(localA);
