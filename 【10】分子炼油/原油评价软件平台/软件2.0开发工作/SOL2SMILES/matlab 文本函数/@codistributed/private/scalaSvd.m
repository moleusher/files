function varargout = scalaSvd(A)
% SCALASVD  ScaLAPACK singular value decomposition

%   Copyright 2006-2012 The MathWorks, Inc.
    
nargoutchk(0, 3);

% When there are no output arguments, the function should still return 
% the singular values.
numOutputs = max(1, nargout);

% Redistribute input according to the default 2dbc distribution scheme.
if ~isa(getCodistributor(A), 'codistributor2dbc')
    A = redistribute(A, codistributor2dbc());
end

aDist = getCodistributor(A);
lbgrid = aDist.LabGrid;
minMN = min(size(A));

codistr1d = codistributor1d();

% Create array descriptor required by ScaLAPACK
descA = arraydescriptor(A);

% Output from ScalaPack is ordered by: singular values, left singular vectors, right singular vectors. 
[svdOut{1:numOutputs}] = parallel.internal.codistextern.denseSvd(getLocalPart(A), ...
                                                  descA, lbgrid(1), lbgrid(2), ...
                                                  aDist.Orientation, isreal(A));
if (numOutputs == 1)
    % The ScaLAPACK output is replicated, but we want a codistributed output.   
    varargout{1} = codistributed.pConstructFromReplicated( svdOut{1}, codistributor1d(1) ); %#ok<DCUNK>
    return;
end

% When there are multiple output arguments, they need to be rearranged.  The
% ScaLAPACK ordering is [S, U, VT] while MATLAB expects [U, S, VT']
codistrU = codistributor2dbc(lbgrid, aDist.BlockSize, ...
                             aDist.Orientation, [size(A,1) minMN]);
dU = codistributed.pDoBuildFromLocalPart(svdOut{2}, codistrU);
varargout{1} = redistribute(dU, codistr1d);
S = codistributed.pConstructFromReplicated(svdOut{1}, codistr1d);
varargout{2} = diag(S);

if (numOutputs == 3)
    codistrV = codistributor2dbc(lbgrid, aDist.BlockSize, ...
                                 aDist.Orientation, [minMN size(A,2)]);
    dVT = codistributed.pDoBuildFromLocalPart(svdOut{3}, codistrV);
    varargout{3} = redistribute(dVT, codistr1d)';
end
