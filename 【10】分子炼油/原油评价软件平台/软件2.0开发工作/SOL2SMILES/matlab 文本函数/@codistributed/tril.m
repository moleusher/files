function B = tril(A,k)
%TRIL Extract lower triangular part of codistributed array
%   T = TRIL(A,K) yields the elements on and below the K-th diagonal of A. 
%   K = 0 is the main diagonal, K > 0 is above the main diagonal and K < 0
%   is below the main diagonal.
%   T = TRIL(A) is the same as T = TRIL(A,0) where T is the lower triangular 
%   part of A.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       T1 = tril(D,1)
%       Tm1 = tril(D,-1)
%   end
%   
%   See also TRIL, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2012 The MathWorks, Inc.

if nargin < 2
    k = 0; 
else
    distributedutil.CodistParser.verifyNonCodistributedInputs({A, k});
    k = distributedutil.CodistParser.gatherIfCodistributed(k);
    if ~isa(A, 'codistributed')
        B = tril(A, k);
        return;
    end
end

if ~ismatrix(A)
    error(message('parallel:distributed:TrilNotMatrix'))
end

distributedutil.CodistParser.verifyDiagIntegerScalar('tril', k);

aDist = getCodistributor(A);
localA = getLocalPart(A);

[localA, aDist] = aDist.hTrilImpl(localA, k);

B = codistributed.pDoBuildFromLocalPart(localA, aDist); %#ok<DCUNK> private static.
