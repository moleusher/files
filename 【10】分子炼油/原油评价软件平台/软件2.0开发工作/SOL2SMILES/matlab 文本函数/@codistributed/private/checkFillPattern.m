function tf = checkFillPattern( A, allowedPatterns )
% Common implementation of ISTRIL, ISDIAG, etc. for codistributed array
%
%   tf = checkFillPattern(A, allowedPatterns) is true if the FillPattern
%   of A is one of the allowedPatterns, false if not.
%
%   See also: codistributed/isdiag, codistributed/istril, codistributed/istriu.

%   Copyright 2016 The MathWorks, Inc.

% See if we already know the answer
if A.Metadata.FillPattern.isKnown()
    % Get the answer from metadata
    matrixType = A.Metadata.FillPattern.get();
    
else
    % Calculate the answer
    codistr = getCodistributor(A);
    LP = getLocalPart(A);
    matrixType = codistr.hIsTriangularImpl(LP);
    % store back into metadata so we don't have to calculate it again
    A.Metadata.FillPattern.set(matrixType);
    
end

tf = ismember(matrixType, allowedPatterns);

end
