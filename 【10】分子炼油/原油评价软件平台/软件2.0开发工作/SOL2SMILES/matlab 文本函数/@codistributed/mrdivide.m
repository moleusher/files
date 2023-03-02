function A = mrdivide(A, B)
%/ Slash or right matrix divide for codistributed array
%   C = A / B
%   C = MRDIVIDE(A,B)
%   
%   A/B is the matrix division of B into A, and is computed using A/B = (B'\A')'.
%   See codistributed/MLDIVIDE for details on functionality and limitations.
%   
%   Example:
%   spmd
%       N = 1000;
%       D1 = codistributed.colon(1, N)';
%       D2 = D1 / 2;
%   end
%   
%   See also MRDIVIDE, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2016 The MathWorks, Inc.

    narginchk(2, 2);

    distributedutil.CodistParser.verifyNonCodistributedInputs({A, B});

    if isscalar(B) || (isscalar(A) && ~ismatrix(B))
        A = codistributed.pElementwiseOp(@rdivide, A, B); %#ok<DCUNK>
        return;
    end

    if iIsUnsupported(A) || iIsUnsupported(B)
        error(message('parallel:distributed:MrdivideNotSupported'));
    end
    
    transposeFirstMatrix = true;
    AT = ctranspose(A);
    
    try 
        [AT, isNearlySingular] = codistributed.pMldivideAndMrdivide(transposeFirstMatrix, ...
                                                          B, AT); %#ok<DCUNK>
    catch ME
        throw(ME);
    end
    
    A = ctranspose(AT);

    if isNearlySingular
        warning(message('parallel:distributed:MrdivideNearlySingularMatrix'));
    end
end
%------------------------------------
function tf = iIsUnsupported(D)
    tf = ~distributedutil.CodistParser.isa(D, 'float') || ~ismatrix(D);
end
