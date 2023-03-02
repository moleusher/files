function s = norm(A,p)
%NORM Matrix or vector norm for codistributed array
%   All norms supported by the built-in function have been overloaded for codistributed arrays.
%   
%   For matrices...
%         N = NORM(D, 2) returns the 2-norm of D.
%         N = NORM(D) is the same as NORM(D, 2).
%         N = NORM(D, 1) is the 1-norm of D.
%         N = NORM(D, inf) is the infinity norm of D.
%         N = NORM(D, 'fro') is the Frobenius norm of D.
%         N = NORM(D, P) is available for matrix D only if P is 1, 2, inf, or 'fro'.
%   
%   For vectors...
%         N = NORM(D, P) is the same as sum(abs(D).^P)^(1/P) for 1 <= P < inf.
%         N = NORM(D) is the same as norm(D, 2).
%         N = NORM(D, inf) is the same as max(abs(D)).
%         N = NORM(D, -inf) is the same as min(abs(D)).
%   
%   Example:
%   spmd
%       N = 1000;
%       D = diag(codistributed.colon(1,N));
%       n = norm(D,1)
%   end
%   
%   returns n = 1000.
%   
%   See also NORM, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.
%   


%   Copyright 2006-2013 The MathWorks, Inc.
    if nargin == 2
        distributedutil.CodistParser.verifyNonCodistributedInputs({A, p});
    end

    if ~ismatrix(A) 
        error(message('parallel:distributed:NormNotVectorOrMatrix'))
    end 
    
    if nargin < 2
        p = 2;
    else 
        p = distributedutil.CodistParser.gatherIfCodistributed(p);
        if ~isa(A, 'codistributed')
            % Only the p was codistributed.
            s = norm(A, p);
            return;
        end 
    end 
    
    if ~isaUnderlying(A,'float')
        error(message('parallel:distributed:NormNotSupported'));
    end  
    
    isVecA = isvector(A);
    
    % Check if p is a supported norm for input A, otherwise throw
    iIsValidNorm(isVecA, p);
    
    % Check for special cases that can exit early
    if isempty(A)
        % Ensure norm of an empty is full and the same type as A
        s = full(zeros(1, 1, 'like', A));
        return;
    elseif isscalar(A)
        % Ensure norm of a scalar is full independent of A
        s = full(abs(A));
        % Return early
        return;
    end
    
    % Check if Forbenius norm is selected
    isFrobenius = false;
    if strcmp(p, 'fro')
        isFrobenius = true;
    elseif isVecA && isnumeric(p)
        % For vectors 2-norm and Frobenius norm is the same
        isFrobenius = p==2;
    end
    
    % Switch between different methods
    if isFrobenius
        % Frobenius norm computation is the same for vectors and matrices
        s = iFrobeniusNorm(A);
    elseif isVecA
        s = iVectorNorm(A, p);
    else
        s = iMatrixNorm(A, p);
    end
    
    % Ensure output is full
    s = full(s);
end % End norm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = iFrobeniusNorm(A)
        LP = getLocalPart(A);
        codistr = getCodistributor(A);
        s = codistr.hFrobeniusNormImpl(LP);
        % Create codistributed output from replicated scalar local parts
        s = codistributed.pDoBuildFromReplicatedScalar(s, 2); %#ok<DCUNK>
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = iVectorNorm(A, p)
% Compute non-trivial vector norms only for supported p.
    switch p
      case {inf, 'inf'} 
        s = max(abs(A));
      case {-inf, '-inf'}
        s = min(abs(A));
      otherwise 
          s = nthroot(sum(abs(A).^p), p);
    end
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = iMatrixNorm(A, p)
% Compute non-trivial matrix norms only for supported p.
    switch p
      case 1 
        s = max(sum(abs(A),1));
      case 2
        if issparse(A)
            ME = MException(message( ...
            'parallel:distributed:NormSparseMat2NormUnsupported'));
            throwAsCaller(ME)
        else
            s = max( svd(A) );
        end 
      case {inf, 'inf'}
        s = max(sum(abs(A),2));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iIsValidNorm(isVecA, p)
% Check if p triggers a supported case

    if (isscalar(p) && isnumeric(p)) || ischar(p)
        % Check if p for vectors A is supported
        if isVecA
            if ischar(p)
                tf = any(strcmpi(p,{'fro','inf','-inf'}));
            else 
                tf = isfloat(p);
            end

            % Error if p is not supported for vectors throw
            if ~tf
                ME=MException(message(...
                    'parallel:distributed:NormVectorNormNotSupport'));
                throwAsCaller(ME)
            end
        else
        % Check if p for vectors A is supported
            if ischar(p)
                tf = any(strcmpi(p,{'fro','inf'}));
            else
                tf = any(p==[1 2 inf]);
            end

            % Error if p is not supported for vectors throw
            if ~tf
                ME = MException(message(...
                    'MATLAB:norm:unknownNorm'));
                throwAsCaller(ME)
            end
        end
    else
        ME = MException(message('parallel:distributed:NormInvalidP'));
        throwAsCaller(ME)
    end
end
