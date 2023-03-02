function C = hMldivideTranspose(A, transposeA, B, transposeB)
%HMLDIVIDETRANSPOSE matrix left-division with transposed inputs
%   
%   HMLDIVIDETRANSPOSE(A, transA, B, transB) performs a matrix left-division
%   of A and B applying transposes to A and B as appropriate. The two transpose
%   flags can have the following values:
%      0  No transpose
%      1  Non-conjugate transpose
%      2  Conjugate transpose
%   
%   Example:
%   spmd
%       A = codistributed([ 1 2; 3 4; 5 6 ]);
%       B = codistributed([ 7 8 9; 10 11 12 ]);
%       C = hMldivideTranspose(A, 0, B, 1); % C is 3x2 
%   end
%   
%   See also: codistributed/mldivide, codistributed/transpose, codistributed/ctranspose, codistributed.
%   


%   Copyright 2014 The MathWorks, Inc.

% For now, simply do the separate operations. We can optimize some cases
% later.
    A = iMaybeTranspose(A, transposeA);
    B = iMaybeTranspose(B, transposeB);
    C = mldivide(A, B);

end


function X = iMaybeTranspose(X, t)
% Perform the appropriate transpose (if any)
    if t==1
        X = transpose(X);
    elseif t==2
        X = ctranspose(X);
    end
end
