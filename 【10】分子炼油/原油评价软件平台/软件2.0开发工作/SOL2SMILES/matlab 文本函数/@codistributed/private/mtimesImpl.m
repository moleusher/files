function C = mtimesImpl(A, B, transA, transB)
% mtimesImpl: Entrance point of mtimes implementations for codistributed 
% inputs that checks inputs and calls appropirate implementation depending 
% on used codistributor

%   Copyright 2016 The MathWorks, Inc.

narginchk(2, 4);

distributedutil.CodistParser.verifyNonCodistributedInputs({A, B});

% Set transpose flags if not provided
if nargin == 2
    transA = 0;
    transB = 0;
elseif nargin == 3
    transB = 0;
end

if isscalar(A) || isscalar(B)
    [A, B] = iMaybeTranspose((transA || transB), A, transA, B, transB);
    C = times(A, B); 
    return
end

iValidateInputArgs(A, B, transA, transB)

areBothMatricesDense = ~(issparse(A) || issparse(B));

isCodistributedA = isa(A, 'codistributed');
isCodistributedB = isa(B, 'codistributed');

if isCodistributedA && isCodistributedB
    % Both A and B are codistributed arrays.
    codistrA = getCodistributor(A);
    codistrB = getCodistributor(B);
    if ~strcmpi(class(codistrA), class(codistrB)) 
        % A & B are of different distribution classes
        % Redistribute to the same class before proceeding
        [A, B, usedCodistrClass] = iUnifyCodistributors(A, B, areBothMatricesDense);
    else
        usedCodistrClass = class(codistrA);
    end
    if ~codistrA.hMtimesCheck(areBothMatricesDense)   % Both are distributed in same class
        A = iConvertTo1d(A);
        B = iConvertTo1d(B);
        usedCodistrClass = 'codistributor1d';
    end

    % If needed, perform transpose operation explicitly for 1d codistributor
    [A, B] = iMaybeTranspose( ...
        strcmp(usedCodistrClass,'codistributor1d') && (transA || transB), ...
        A, transA, B, transB);
    
    [localA, codistrA] = iExtractCodistrAndLP(A);
    [localB, codistrB] = iExtractCodistrAndLP(B);
    [localC, codistrC] = codistrA.hMtimesImpl(codistrA, localA, transA, ...
                                              codistrB, localB, transB);
else % One array is codistributed; the other is replicated
    usedCodistrClass = '';
    if ~iIsValidCodistributor(A, areBothMatricesDense)
        A = iConvertTo1d(A);
        usedCodistrClass = 'codistributor1d';
    end
    
    if ~iIsValidCodistributor(B, areBothMatricesDense)
        B = iConvertTo1d(B);
        usedCodistrClass = 'codistributor1d';
    end

    % Set used codistributor if not done above
    if isempty(usedCodistrClass)
        if isCodistributedA
            usedCodistr = getCodistributor(A);
        else
            usedCodistr = getCodistributor(B);
        end
        usedCodistrClass = class(usedCodistr);
    end
    
    % If needed, perform transpose operation explicitly for 1d codistributor
    [A, B] = iMaybeTranspose( ...
        strcmp(usedCodistrClass,'codistributor1d') && (transA || transB), ...
        A, transA, B, transB);
    
    [localA, codistrA]  = iExtractCodistrAndLP(A);
    [localB, codistrB]  = iExtractCodistrAndLP(B);    
    if ~isempty(codistrA)
        codistr = codistrA;
    else
        codistr = codistrB;
    end
    [localC, codistrC] = codistr.hMtimesReplicatedImpl(codistrA, localA, transA, ...
                                                       codistrB, localB, transB);
end
C = codistributed.pDoBuildFromLocalPart(localC, codistrC); %#ok<DCUNK>

end % End of mtimes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iValidateInputArgs(A, B, transA, transB)
    if ~distributedutil.CodistParser.isa(A, 'float') || ...
            ~distributedutil.CodistParser.isa(B, 'float')
        ME = MException(message('MATLAB:mtimes:integerNotSupported'));
        throwAsCaller(ME);
    end
    
    if ~ismatrix(A) || ~ismatrix(B)
        ME = MException(message('MATLAB:mtimes:inputsMustBe2D'));
        throwAsCaller(ME);
    end
    
    % Determine inner dimensions
    if transA
        innerDimensionA = size(A,1);
    else
        innerDimensionA = size(A,2);
    end
    if transB
        innerDimensionB = size(B,2);
    else
        innerDimensionB = size(B,1);
    end
    % Check that inner dimmension fits
    if innerDimensionA ~= innerDimensionB
        ME = MException(message('MATLAB:innerdim'));
        throwAsCaller(ME);
    end
end

function [A, B, usedCodistrClass] = iUnifyCodistributors(A, B, areBothMatricesDense)
    codistrA = getCodistributor(A);
    codistrB = getCodistributor(B);
    usedCodistrClass = '';
    if numel(A) > numel(B)
        if codistrA.hMtimesCheck(areBothMatricesDense)
            codistrB = codistrA.hGetNewForSize( size(B) );
            B = redistribute(B, codistrB);
        else
            if codistrB.hMtimesCheck(areBothMatricesDense)
                codistrA = codistrB.hGetNewForSize( size(A) );
                A = redistribute(A, codistrA);
            else
                A = iConvertTo1d(A);
                B = iConvertTo1d(B);
                usedCodistrClass = 'codistributor1d';
            end
        end
    else
        if codistrB.hMtimesCheck(areBothMatricesDense)
            codistrA = codistrB.hGetNewForSize( size(A) );
            A = redistribute(A, codistrA);
        else
            if codistrA.hMtimesCheck(areBothMatricesDense)
                codistrB = codistrA.hGetNewForSize( size(B) );
                B = redistribute(B, codistrB);
            else
                A = iConvertTo1d(A);
                B = iConvertTo1d(B);
                usedCodistrClass = 'codistributor1d';
            end  
        end
    end
    % Determine which codistributor is used afterwards if not yet defined
    if isempty(usedCodistrClass)
        usedCodistrClass = class(codistrA);
    end
end

function A = iConvertTo1d(A)
% To be called if hMtimesCheck fails for the distributions of an input
    [~, dim] = max(size(A));
    A = redistribute(A, codistributor1d(dim));
end

function [LP, codistr] = iExtractCodistrAndLP(D)
    if isa(D, 'codistributed')
        % Get codistributor and local part from codistributed array.
        LP = getLocalPart(D);
        codistr = getCodistributor(D);
    else
        % Let empty codistributor indicate that local part represents a
        % replicated array.
        LP = D;
        codistr = [];
    end
end

function tf = iIsValidCodistributor(X, areBothMatricesDense)
    if isa(X, 'codistributed')
        tf = hMtimesReplicatedCheck( getCodistributor(X), areBothMatricesDense );
    else
        % replicated array has a "valid" codistributor
        tf = true;
    end
end

function [A, B] = iMaybeTranspose(performTrans, A, transA, B, transB)
% Perform the appropriate transposes (if any)
if performTrans
    if transA==1
        A = transpose(A);
    elseif transA==2
        A = ctranspose(A);
    end
    if transB==1
        B = transpose(B);
    elseif transB==2
        B = ctranspose(B);
    end
end
end