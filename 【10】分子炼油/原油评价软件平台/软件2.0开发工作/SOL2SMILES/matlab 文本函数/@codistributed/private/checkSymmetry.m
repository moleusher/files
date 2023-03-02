function tf = checkSymmetry( A, doConj, isSkew )
% Common code for checking symmetry of a codistributed array
%
%   tf = checkSymmetry(A, doConj, isSkew) is true if the input A is a
%   matrix and has symmetry with optional conjugation and skew. This
%   is used by ISSYMMETRIC and ISHERMITIAN. Note that the result is
%   cached in metadata, making subsequent queries effectively free.
%
%   See also: codistributed/issymmetric, codistributed/ishermitian.

%   Copyright 2016 The MathWorks, Inc.

% If not square then always false
if ~ismatrix(A) || size(A,1)~=size(A,2)
    tf = false;
    return
end

% See if we already know the answer
if A.Metadata.Symmetry.isKnown()
    % Get the answer from metadata
    symmType = A.Metadata.Symmetry.get();
    
else
    % Calculate the answer
    symmType = iDetermineSymmetry(A);
    % store back into metadata so we don't have to calculate it again
    A.Metadata.Symmetry.set(symmType);
    
end

if isreal(A) || ~doConj
    if isSkew
        % Skew-symmetric (A == -A.')
        patterns = {'AllZero', 'SkewSymmetric'};
    else
        % Symmetric (A == A.')
        patterns = {'AllZero', 'Symmetric'};
    end
    
else
    if isSkew
        % Skew-Hermitian (A == -A')
        patterns = {'AllZero', 'SkewHermitian'};
    else
        % Hermitian (A == A')
        patterns = {'AllZero', 'Hermitian'};
    end
    
end

tf = ismember(symmType, patterns);

end


function symmType = iDetermineSymmetry(A)
% Determine if a square matrix has any symmetry

% First create the transpose
B = transpose(A);

% Redistribute to have the same local parts
B = redistribute(B, getCodistributor(A));

% Now compare the local parts to see if this part obeys any symmetry
lpA = getLocalPart(A);
lpB = getLocalPart(B);
isSymm = isequal(lpA, lpB);
isSkewSymm = isequal(lpA, -lpB);
if isreal(A)
    isHerm = isSymm;
    isSkewHerm = isSkewSymm;
else
    isHerm = isequal(lpA, conj(lpB));
    isSkewHerm = isequal(lpA, -conj(lpB));
end

% Only true for entire matrix if true for all local parts
globalSymm = gop( @and, [isSymm, isSkewSymm, isHerm, isSkewHerm] );

% Now interpret the result into a string. Default is none.
symmType = 'NoSymmetry';

if globalSymm(1)
    if globalSymm(2)
        % If both symmetric and skew-symmetric, it must be all-zero
        symmType = 'AllZero';
    else
        symmType = 'Symmetric';
    end
    
elseif globalSymm(2)
    symmType = 'SkewSymmetric';

elseif globalSymm(3)
    symmType = 'Hermitian';
    
elseif globalSymm(4)
    symmType = 'SkewHermitian';

end

end % iDetermineSymmetry
