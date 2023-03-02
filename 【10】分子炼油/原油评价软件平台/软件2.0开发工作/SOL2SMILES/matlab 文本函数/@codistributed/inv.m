function A = inv(A)
%INV    Matrix inverse for codistributed arrays
%   X = INV(C) is the inverse of codistributed matrix C.
%   
%   C must be a square full codistributed matrix of floating 
%   point numbers (single or double).
%   
%   Example:
%   C multiplied on either side by its inverse should be close to the
%   identity matrix.
%   
%   spmd
%       N = 1000;
%       C = codistributed.rand(N);
%       Cinv = inv( C );
%       CinvTimesC = norm(codistributed.eye(N) - Cinv*C)
%       CTimesCinv = norm(codistributed.eye(N) - C*Cinv)
%   end
%   
%   See also INV, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2010-2012 The MathWorks, Inc.

narginchk(1, 1);

% Quick return if array is empty
if isempty(A)
    return;
end

% Validate argument
iValidateInputArg(A);

codistrA = getCodistributor(A);
if isa(codistrA, 'codistributor2dbc')
    codistrEye = codistrA;
else
    codistrEye = codistributor2dbc(codistributor2dbc.defaultLabGrid, ...
                                   codistributor2dbc.defaultBlockSize, ...
                                   'col', size(A));
end
        
try
    A = A\codistributed.eye(size(A), classUnderlying(A), codistrEye);
catch ME
    throw(ME);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iValidateInputArg(A)
    if ~distributedutil.CodistParser.isa(A, 'float')
        ME = MException(message('parallel:distributed:InvInputMustBeFloat'));
        throwAsCaller(ME);
    end
    
    if ~ismatrix(A)
        ME = MException(message('parallel:distributed:InvInputMustBe2D'));
        throwAsCaller(ME);
    end
    
    if size(A, 2) ~= size(A, 1)
        ME = MException(message('parallel:distributed:InvInputMustBeSquare'));
        throwAsCaller(ME);
    end
end
