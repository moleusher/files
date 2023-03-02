function [A, I] = sortrows(A, col)
%SORTROWS Sort rows of codistributed array matrix in ascending order.
%   Y = SORTROWS(X)
%   Y = SORTROWS(X,COL)
%   [Y,I] = SORTROWS(X)   
%   [Y,I] = SORTROWS(X,COL)
%   
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.randn(N, N);
%       E = sortrows(D);
%   end
%   
%   E contains the rows of D reordered according to the result of sorting the 
%   first column of D with ties broken by considering further columns of D.
%   
%   See also SORTROWS, CODISTRIBUTED, CODISTRIBUTED.RANDN


%   Copyright 2013-2015 The MathWorks, Inc.

    narginchk(1, 2);
    nargoutchk(0, 2);

    if nargin == 2
        distributedutil.CodistParser.verifyNonCodistributedInputs({A, col});
        col = distributedutil.CodistParser.gatherIfCodistributed(col);
    else
        col = 1:size(A, 2);  % default
    end

    % if A isn't codistributed, call MATLAB function
    if ~isa(A, 'codistributed')
        [A, I] = sortrows(A, col);
        return
    end

    % quick return if A is empty
    codistr = getCodistributor(A);
    if isempty(A)
        if isequal(size(A), [0 0])
            I = [];
        else
            I = (1:size(A, 1))';
        end
        codistrI = codistr.hGetNewForSize(size(I));
        I = codistributed.pConstructFromReplicated(I, codistrI); %#ok<DCUNK>
        return
    end

    iCheckArgs(A, col);
    origCodistr = codistr;

    % redistribute if necessary
    if ~codistr.hSortrowsCheck
        A = redistribute(A, codistributor1d(2));
        codistr = getCodistributor(A);
    end

    LPA = getLocalPart(A);
    if nargin == 1
        [LPA, I] = codistr.hSortrowsDefaultImpl(LPA);
    elseif isscalar(col)
        [LPA, I] = codistr.hSortrowsOneColImpl(LPA, col);
    else
        [LPA, I] = codistr.hSortrowsGeneralImpl(LPA, col);
    end
    A = codistributed.pDoBuildFromLocalPart(LPA, codistr); %#ok<DCUNK>
    A = redistribute(A, origCodistr);
    if nargout > 1
        codistrI = origCodistr.hGetNewForSize(size(I));
        I = codistributed.pConstructFromReplicated(I, codistrI); %#ok<DCUNK>
    end
end

function iCheckArgs(A, col)
    col = abs(col);
    if ~isPositiveIntegerValuedNumeric(col, false) || ~isvector(col) ...
            || max(col) > size(A, 2)
        ex = MException(message('MATLAB:sortrows:COLmismatchX'));
        throwAsCaller(ex);
    end
    isSortableType = any(cellfun(@(x)isaUnderlying(A,x), {'numeric', 'char', ...
                        'logical'})) || iscellstr(A);
    if ~isSortableType
        ex = MException(message('parallel:distributed:SortrowsUnsupportedClass'));
        throwAsCaller(ex);
    end
    if ~ismatrix(A)
        ex = MException(message('parallel:distributed:SortrowsFirstInputMustBe2D'));
        throwAsCaller(ex);
    end
end
