function varargout = scalaChol(A, enumUpLow)
% SCALACHOL  ScaLAPACK Cholesky factorization

%   Copyright 2006-2012 The MathWorks, Inc.

narginchk(2,2);

% Redistribute input according to the default 2dbc distribution scheme.
if ~isa(getCodistributor(A), 'codistributor2dbc')
    A = redistribute(A, codistributor2dbc());
end

distA = getCodistributor(A);
lbgrid = distA.LabGrid;

isrealA = isreal(A);
localA = getLocalPart(A);

descA = arraydescriptor(A);

if ~isrealA && isreal(localA)
     localA = complex(localA);
end

[localA, p] = parallel.internal.codistextern.denseChol(localA, descA, ...
                                                  lbgrid(1), lbgrid(2), ...
                                                  distA.Orientation, ...
                                                  enumUpLow, isrealA);
codistr = codistributor2dbc(lbgrid, distA.BlockSize,  ...
                            distA.Orientation, size(A));

A = codistributed.pDoBuildFromLocalPart(localA, codistr); %#ok<DCUNK>

A = redistribute(A, codistributor1d(2));

% The leading N-by-N triangular part of A contains the factored matrix,
% (upper by default, but lower if there are two input arguments)
% and its strictly (lower, resp. upper) triangular part is not referenced.  
% Extract the factor of interest from A.
if strcmpi(enumUpLow, 'upper')
    varargout{1} = triu(A);
else
    varargout{1} = tril(A);
end
varargout{2} = p;
