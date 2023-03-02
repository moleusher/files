function A = diag(A, k)
%DIAG Diagonal matrices and diagonals of a codistributed matrix
%   
%   A = DIAG(D,K) when D is a codistributed vector with N components results 
%   in a square codistributed matrix A of order N+ABS(K) with the elements of 
%   D along the K-th diagonal of A.  Recall that K = 0 is the main diagonal, 
%   K > 0 is above the main diagonal, and K < 0 is below the main diagonal.
%   
%   A = DIAG(D) is the same as A = DIAG(D,0) and puts D along the main 
%   diagonal of A.
%   
%   D = DIAG(A,K) when A is a codistributed matrix results in a codistributed 
%   column vector D formed from the elements of the K-th diagonal of A.  
%   
%   D = DIAG(A) is the same as D = DIAG(A,0) and D is the main diagonal 
%   of A. Note that DIAG(DIAG(A)) results in a codistributed diagonal matrix.
%   
%   Example:
%   spmd
%       N = 1000;
%       d = codistributed.colon(N,-1,1)'
%       d2 = codistributed.colon(1,ceil(N/2))'
%       D = diag(d) + diag(d2,floor(N/2))
%   end
%   
%   creates two codistributed column vectors d and d2 and then populates the
%   codistributed matrix D with them as diagonals.
%   
%   See also DIAG, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.
%   


%   Copyright 2006-2012 The MathWorks, Inc.

if ~ismatrix(A)
    error(message('parallel:distributed:DiagFirstInputMustBe2D'));
end

if nargin < 2
    k = 0; %Default
else
    distributedutil.CodistParser.verifyNonCodistributedInputs({A, k});
    k = distributedutil.CodistParser.gatherIfCodistributed(k);
end

if ~isa(A, 'codistributed')
    A = diag(A, k);
    return;
end

if any(strcmp(classUnderlying(A), {'struct', 'cell'}))
    error(message('parallel:distributed:DiagClassUnderlyingNotSupported', classUnderlying( A )));
end

distributedutil.CodistParser.verifyDiagIntegerScalar('diag', k);

aDist = getCodistributor(A);

% Throw an error for unsupported codistributors.
if ~aDist.hDiagCheck()
    error(message('parallel:distributed:DiagCodistributorNotSupported', class( aDist )));
end

localA = getLocalPart(A);
if isempty(A)
    % Note that 1x0 and 0x1 result in kxk. Other empties result in 0x0.
    if isequal(size(A), [0 1]) || isequal(size(A), [1 0])
        outSz = abs([k, k]);        
    else
        outSz = [0, 0];
    end
    aDist = hGetNewForSize(aDist, outSz);
    localA = distributedutil.Allocator.create(aDist.hLocalSize(), localA);
elseif isvector(A)
    [localA, aDist] = aDist.hDiagVecToMatImpl(localA, k);
else
    [localA, aDist] = aDist.hDiagMatToVecImpl(localA, k);
end
    
A = codistributed.pDoBuildFromLocalPart(localA, aDist); %#ok<DCUNK>
