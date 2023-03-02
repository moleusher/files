function varargout = eig(varargin)
%EIG Eigenvalues and eigenvectors of codistributed array
%   D = EIG(A)
%   [V,D] = EIG(A)
%   [...] = EIG(A,'balance')
%   [...] = EIG(A,B)
%   [...] = EIG(A,B,'chol')
%   
%   A (and B, if present) must be real symmetric or complex Hermitian.
%   
%   The following syntaxes are not supported for full codistributed array:
%   [...] = EIG(A,'nobalance')
%   [...] = EIG(A,B,'qz')
%   
%   Example:
%   spmd
%       N = 1000;
%       A = codistributed.rand(N);
%       A = A+A';  % create a real, symmetric matrix A
%       [V,D] = eig(A);
%       norm(A*V-V*D, 1)  % A*V is within round-off error of V*D 
%   end
%   
%   See also EIG, CODISTRIBUTED, CODISTRIBUTED/RAND.

%   Copyright 2006-2016 The MathWorks, Inc.

    narginchk(1, 4);
    nargoutchk(0, 3);

    distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);

    [numericArgs, flags] = iParseArgs(varargin);
    if any(cellfun(@iIsUnsupported, numericArgs))
        error(message('parallel:distributed:EigNotReal'));
    end

    % are no numeric arguments codistributed?
    if ~any(cellfun(@(x) isa(x, 'codistributed'), numericArgs))
        % flag was codistributed but matrices were not - pass to MATLAB
        [varargout{1:nargout}] = eig(numericArgs{:}, flags);
        return
    end

    A = numericArgs{1};
    
    if nargout == 3
        error(message('parallel:array:EigUnsupportedLeftVectors', class(A)));
    end
    
    if ~isequaln(A, A')
        error(message('parallel:distributed:EigNoNonSymEig'))
    end

    % Check for vector or matrix
    [isvec,flags] = iCheckVectorMatrixFlag(nargout, flags);
    
    if length(numericArgs) == 1   % standard eig case
        iCheckFlags(flags);
        if isempty(A)
            [varargout{1:nargout}] = iEigEmpty(numericArgs, isvec);
        else
            [varargout{1:nargout}] = scalaEig(A, isvec);            
        end    
        return
    end

    % generalized eig case
    B = numericArgs{2};
    if isempty(flags)
        usechol = true;
    else
        usechol = iCheckGeneralizedFlag(flags{1});
    end
    
    % check that A & B are the same size
    if ~isequal(size(A), size(B))
        error(message('MATLAB:dimagree'));
    end

    % deal with the case of empty inputs because ScaLAPACK doesn't
    if isempty(A)
        [varargout{1:nargout}] = iEigEmpty(numericArgs);
        return
    end    
    
    % check that B is symmetric and if so do generalized problem
    if usechol && isequaln(B, B')
        [varargout{1:nargout}, isDecompSuccessful] = scalaGeneralizedEig(A, B, usechol, isvec);
        if ~isDecompSuccessful
            error(message('parallel:distributed:EigBMustBePosDef'));
        end
    else  % 'qz' code would be called in this case
        error(message('parallel:distributed:EigUnsupportedSyntax'));
    end
end

function [numericArgs, flags] = iParseArgs(argList)

    trailingArgIdx = find(cellfun(@(x) ischar(x) || isstring(x), argList), 1, 'first');
    
    if isempty(trailingArgIdx)
        % All data
        numericArgs = argList;
        flags = {};
    elseif trailingArgIdx == 1
        % All flags
        numericArgs = {};
        flags = argList;
    else
        numericArgs = argList(1:trailingArgIdx-1);
        flags = argList(trailingArgIdx:end);
    end
    
    % No data inputs is an error
    if isempty(numericArgs)
        ME = MException(message('parallel:distributed:EigNotReal'));
        throwAsCaller(ME);
    end
    
    
    % More than two data inputs is an error
    if numel(numericArgs)>2
        ME = MException(message('parallel:array:EigUnknownThirdArgument'));
        throwAsCaller(ME);
    end
    
    % All flags must be char vectors or strings
    if any(~cellfun(@(x) ischar(x) || (isstring(x) && isscalar(x)), flags))
        ME = MException(message('parallel:distributed:EigUnsupportedSyntax'));
        throwAsCaller(ME);
    end
    
end

function [isvec,flags] = iCheckVectorMatrixFlag(numOut, flags)
% Determine whether to return eigenvalues as a vector or matrix

% Default for eigenvalues is vector for 1 output, matrix for 2.
isvec = (numOut == 1);

% Find whichever is specified last (i.e. {'vector', 'matrix'} ==> 'matrix')
matvecFlags = ismember(lower(flags), {'vector','matrix'});
idx = find(matvecFlags, 1, 'last');
if ~isempty(idx)
    isvec = strcmpi(flags{idx}, 'vector');
end

% Now remove them from the list
flags(matvecFlags) = [];
end

function iCheckFlags(flags)
    for ii=1:numel(flags)
        if ~ismember(lower(flags{ii}), {'balance', 'nobalance', 'vector', 'matrix'})
            ME = MException(message('parallel:array:EigUnknownSecondArgument'));
            throwAsCaller(ME);
        end
        if strcmpi(flags{ii}, 'nobalance')
            ME = MException(message('parallel:distributed:EigUnsupportedSyntax'));
            throwAsCaller(ME);
        end
    end
end

function useChol = iCheckGeneralizedFlag(flag)
    if ~any(strcmpi(flag, {'chol', 'qz'}))
        ME = MException(message('parallel:array:EigUnknownThirdArgument'));
        throwAsCaller(ME);
    end
    if strcmpi(flag, 'qz')
        ME = MException(message('parallel:distributed:EigUnsupportedSyntax'));
        throwAsCaller(ME);
    end
    useChol = strcmpi(flag, 'chol');
end

function tf = iIsUnsupported(A)
    tf = ~distributedutil.CodistParser.isa(A, 'float') || ~ismatrix(A) || issparse(A);
end

function varargout = iEigEmpty(numericArgs, isvec)
% we got here because all of numericArgs are empty

if nargout==0
    return
end

    isArgCodistributed = cellfun(@(x) isa(x, 'codistributed'), numericArgs);
    firstCodistributedArg = find(isArgCodistributed, 1, 'first');
    firstCodistributedMatrix = numericArgs{firstCodistributedArg};
    codistr = getCodistributor(firstCodistributedMatrix);
    if any(cellfun(@(x) distributedutil.CodistParser.isa(x, 'single'), numericArgs))
        typeArg = 'single';
    else
        typeArg = 'double';
    end
    
    if isvec
        codistr = codistr.hGetNewForSize([0 1]);
        eigenVals = zeros(0, 1, typeArg, codistr);
    else
        eigenVals = zeros(0, 0, typeArg, codistr);
    end
    
    switch nargout
      case 1
        % Just the eigenvalues
        varargout{1} = eigenVals;
      case 2
        % Eigenvectors, Eigenvalues
        codistr = codistr.hGetNewForSize([0 0]);
        varargout{1} = zeros(0, 0, typeArg, codistr);
        varargout{2} = eigenVals;
    end
end


