function D = spones(D)
%SPONES Replace nonzero sparse codistributed matrix elements with ones
%   D2 = SPONES(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed(sprand(N,N,1/N));
%       D2 = spones(D1)
%   end
%   
%   returns D2 with the same sparsity structure as D1, but 1's in the nonzero
%   positions.
%   
%   t1 = issparse(D1)
%   t2 = issparse(D2)
%   
%   returns t1 and t2 both equal to true.
%   
%   See also SPONES, CODISTRIBUTED, CODISTRIBUTED/SPRAND.
%   


%   Copyright 2006-2016 The MathWorks, Inc.

% Input may be full or sparse.  Guard against ND-full input.
if ~ismatrix(D)
    error(message('parallel:distributed:SparseNDNotSupported'));
end

codistr = getCodistributor(D);
[D, codistr] = ifNotSupportedSparseRedistributeTo1d(D, codistr);
LP = getLocalPart(D);
clear D;

% Apply spones to all the parts of the array, redistribute if necessary.
[LP, codistr] = codistr.hSparsifyImpl(@spones, LP);

D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
