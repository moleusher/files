function A = mldivide(A, B)
%\ Backslash or left matrix divide for codistributed arrays
%   X = A \ B
%   X = MLDIVIDE(A,B)
%   
%   A and B must be codistributed arrays of floating point numbers (single or double).
%   If A is rectangular, A must also be a full codistributed array. 
%   
%   The MATLAB MLDIVIDE function prints a warning message if A is
%   badly scaled, nearly singular, or rank deficient.  codistributed/MLDIVIDE 
%   cannot check for this condition; therefore, it is unable to warn
%   if there is a violation. You should be aware of this possibility
%   and take action to avoid it.
%   
%   If A is an M-by-N matrix with N > M, codistributed/MLDIVIDE computes
%   a solution X which minimizes NORM(X). This is the same as the
%   result of PINV(A)*B.
%   
%   Example:
%   spmd
%       N = 1000;
%       A = codistributed.rand(N);
%       B = codistributed.rand(N,1);
%       X = A \ B;
%       norm(B-A*X, 1)
%   end
%   
%   See also MLDIVIDE, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2015 The MathWorks, Inc.

    narginchk(2, 2);

    distributedutil.CodistParser.verifyNonCodistributedInputs({A, B});

    if isscalar(A) || (isscalar(B) && ~ismatrix(A))
        A = codistributed.pElementwiseOp(@ldivide, A, B); %#ok<DCUNK>
        return;
    end

    if iIsUnsupported(A) || iIsUnsupported(B)
        error(message('parallel:distributed:MldivideNotSupported'));
    end

    transposeFirstMatrix = false;
    
    try 
        [A, isNearlySingular] = codistributed.pMldivideAndMrdivide(transposeFirstMatrix,...
                                                          A, B); %#ok<DCUNK>
    catch ME
        throw(ME);
    end
    
    if isNearlySingular
        warning(message('parallel:distributed:MldivideNearlySingularMatrix'));
    end
end
%------------------------------------
function tf = iIsUnsupported(D)
    tf = ~distributedutil.CodistParser.isa(D, 'float') || ~ismatrix(D);
end
