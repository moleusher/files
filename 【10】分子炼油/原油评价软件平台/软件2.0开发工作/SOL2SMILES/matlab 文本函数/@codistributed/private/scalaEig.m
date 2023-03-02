function varargout = scalaEig(A, isvec)
% SCALAEIG  ScaLAPACK symmetric eigenvalue solver

%   Copyright 2006-2016 The MathWorks, Inc.

nargoutchk(0, 2);

% When there are no output arguments, the function should still return
% the eigenvalues.
numOutputs = max(1, nargout);

% Check for NaNs and Infs
if all(all(isfinite(A))) == false
    ME = MException(message('parallel:distributed:EigMatrixWithNaNInf'));
    throwAsCaller(ME);
end

% Redistribute input according to the default 2dbc distribution scheme.
if ~isa(getCodistributor(A), 'codistributor2dbc')
    A = redistribute(A, codistributor2dbc());
end

aDist = getCodistributor(A);
lbgrid = aDist.LabGrid;
localA = getLocalPart(A);

codistr1d = codistributor1d();

% Create array descriptor required by ScaLAPACK
descA = arraydescriptor(A);

% Output from ScalaPack is ordered with eigenvalues first, then eigenvectors.
[eigOut{1:numOutputs}] = parallel.internal.codistextern.denseEig(localA, descA, lbgrid(1), lbgrid(2), aDist.Orientation, isreal(A));

% We always need the values.
% The ScaLAPACK output is replicated but we want codistributed output.
eigenVals = codistributed.pConstructFromReplicated( eigOut{1}, codistributor1d(1) );%#ok<DCUNK>
if ~isvec
    eigenVals = diag(eigenVals);
end

if (numOutputs == 1)
    varargout{1} = eigenVals;

else % nargout == 2
     % When there are multiple output arguments, they need to be rearranged.  The
     % ScaLAPACK ordering is [evals, evecs] while MATLAB expects [evecs, evals]
    codistr = codistributor2dbc(lbgrid, aDist.BlockSize, aDist.Orientation, size(A));
    A = codistributed.pDoBuildFromLocalPart(eigOut{2}, codistr); %#ok<DCUNK>
    varargout{1} = redistribute(A, codistr1d);
    
    varargout{2} = eigenVals;
end


