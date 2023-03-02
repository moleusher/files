function [A, I] = sort(A, varargin)
%SORT Sort codistributed array in ascending or descending order.
%   Y = SORT(X)
%   Y = SORT(X, MODE)
%   Y = SORT(X, DIM, MODE)   
%   [Y,I] = SORT(X, ...) also returns an index matrix I.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.randn(N, N);
%       E = sort(D);
%   end
%   codistributed Array E contains the elements of D sorted by columns
%   See also SORT, CODISTRIBUTED, CODISTRIBUTED/RANDN


%   Copyright 2011-2014 The MathWorks, Inc.

narginchk(1, 3);
nargoutchk(0, 2);

distributedutil.CodistParser.verifyNonCodistributedInputs([{A}, varargin]);
argList = distributedutil.CodistParser.gatherElements(varargin);
if ~isa(A, 'codistributed')
    % Only the optional arguments were codistributed.
    [A, I] = sort(A, argList{:});
    return;
end

trailingArgs = iCheckInput(A, argList);
LPA = getLocalPart(A); 
codistrA = getCodistributor(A);
origCodistrA = codistrA;
wantI = (nargout == 2);
dimToSort = trailingArgs{1};

% Short circuit cases:
if isempty(A) || (size(A, dimToSort) == 1)
    [A, I] = iHandleTrivialSort(codistrA, A, trailingArgs, wantI);
    return
end

if numlabs == 1
    [A, I] = iDoLocalSort(codistrA, A, trailingArgs, wantI);
    return
end

if numel(A) == size(A, dimToSort)  % vector
    if ~codistrA.hSortVectorCheck()
        [LPA, codistrA] = distributedutil.Redistributor.redistribute(codistrA, ...
         LPA, codistributor1d(1));
    end
    [LPA, LPI, codistrA] = codistrA.hSortVectorImpl(LPA, trailingArgs, wantI);
else % matrix
    if ~codistrA.hSortArrayCheck()
        [LPA, codistrA] = distributedutil.Redistributor.redistribute(codistrA, ...
         LPA, codistributor1d(1));
    end
    [LPA, LPI, codistrA] = codistrA.hSortArrayImpl(LPA, trailingArgs, wantI);
end

if wantI
    I = codistributed.pDoBuildFromLocalPart(LPI, codistrA); %#ok<DCUNK>
    if ~iscell(LPA)
        I = redistribute(I, origCodistrA);
    end
end

A = codistributed.pDoBuildFromLocalPart(LPA, codistrA); %#ok<DCUNK>
if ~iscell(LPA)
    A = redistribute(A, origCodistrA);
end

function cellOfDimAndMode = iCheckInput(A, argList)
    isACell = iscellstr(A);
    isSortableType = any(cellfun(@(x)isaUnderlying(A,x), {'numeric', 'char', ...
              'logical'})) || isACell;
    if ~isSortableType
        error(message('parallel:distributed:SortClassUnderlyingNotSupported'));
    end
    numOptionalArgs = length(argList);
    
    if isACell && (numOptionalArgs > 0)
        error(message('parallel:distributed:SortTooManyInputs'));
    end
    
    % default values for mode and dim
    mode = 'ascend';
    dim = distributedutil.Sizes.firstNonSingletonDimension(size(A));
    
    switch numOptionalArgs
        case 0
            cellOfDimAndMode = { dim, mode };
            return
        case 1
            if ischar(argList{1})
                mode = argList{1};
            else
                dim = argList{1};
            end
        case 2
            dim = argList{1};
            mode = argList{2};
    end
    if ~(isscalar(dim) && isPositiveIntegerValuedNumeric(dim))
        error(message('MATLAB:sort:notPosInt'));
    end
    
    if ~any(strcmpi(mode, {'ascend', 'descend'}))
        error(message('MATLAB:sort:sortDirection'));
    end
    
    cellOfDimAndMode = {dim, mode};
end

function [A, I] = iHandleTrivialSort(codistrA, A, trailingArgs, wantI)
I = [];
if isempty(A)
    if wantI
        LPI = distributedutil.Allocator.create(codistrA.hLocalSize(), I);
        I = codistributed.pDoBuildFromLocalPart(LPI, codistrA); %#ok<DCUNK>
    end
elseif (size(A, trailingArgs{1}) == 1)
    if wantI
        I = codistributed.ones(size(A), codistrA);
    end
end
end

function [A, I] = iDoLocalSort(codistrA, A, trailingArgs, wantI)
I = [];
LPA = getLocalPart(A);
[LPA, LPI] = sort(LPA, trailingArgs{:});
szA = size(LPA);
codistrA = codistrA.hGetNewForSize(szA);
A = codistributed.pDoBuildFromLocalPart(LPA, codistrA); %#ok<DCUNK>
if wantI
    I = codistributed.pDoBuildFromLocalPart(LPI, codistrA); %#ok<DCUNK>
end
end
end % End of sort
