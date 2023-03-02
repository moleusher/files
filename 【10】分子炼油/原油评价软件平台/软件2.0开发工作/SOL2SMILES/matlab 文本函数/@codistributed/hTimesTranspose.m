function C = hTimesTranspose(A, transposeA, B, transposeB)
%HTIMESTRANSPOSE matrix multiply with transposed inputs
%   
%   HTIMESTRANSPOSE(A, transA, B, transB) performs a matrix-matrix multiply
%   of A and B applying transposes to A and B as appropriate. The two transpose
%   flags can have the following values:
%      0  No transpose
%      1  Non-conjugate transpose
%      2  Conjugate transpose
%   
%   Example:
%   spmd
%       A = codistributed([ 1 2 3; 4 5 6 ]);
%       B = codistributed([ 7 8 9; 10 11 12 ]);
%       C = hTimesTranspose(A, 0, B, 1); % C is 2x2 
%   end
%   
%   See also: codistributed/mtimes, codistributed/transpose, codistributed/ctranspose, codistributed.
%   


%   Copyright 2014-2016 The MathWorks, Inc.

% Keep an eye out for special cases that must produce symmetric output.
forceSymmetric = iResultShouldBeSymmetric(A, transposeA, B, transposeB);

try 
    C = mtimesImpl(A, B, transposeA, transposeB);
catch ME
    throwAsCaller(ME);
end

% Maybe force symmetry
if forceSymmetric
    C = 0.5.*(C+C.');
end
end

function tf = iResultShouldBeSymmetric(A, transposeA, B, transposeB)
% Check for special cases that must produce symmetric output. In
% particular: A'*A and A*A' for real A, or A.'*A and A*A.' for complex A.
tf = false;

% Check if one of the inputs is scalar
if isscalar(A) || isscalar(B)
    return
end

% Check for case where result is a scalar
isRowA = (iscolumn(A) && transposeA) || (isrow(A) && ~transposeA);
isColumnB = (iscolumn(B) && ~transposeB) || (isrow(B) && transposeB);
% If result will be scalar, exit early
if isRowA && isColumnB
    return
end

% False if both inputs are transposed (unless B=A.')
if transposeA>0 && transposeB>0
    return
end

% False if complex and we are conjugating
if (~isreal(A) && transposeA==2) || (~isreal(B) && transposeB==2)
    return
end

% OK, result will be symmetric if both inputs are the same (this is
% expensive, but unavoidable).
tf = isequal(A, B);
end
