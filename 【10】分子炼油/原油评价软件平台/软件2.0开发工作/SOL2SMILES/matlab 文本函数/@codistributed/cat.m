function C = cat(catdim,varargin)
%CAT Concatenate codistributed arrays
%   C = CAT(DIM,A,B,...) implements CAT(DIM,A,B,...) for codistributed arrays.
%   If all of A, B, ... are distributed by the DIM-th dimension, so is C.
%   If any of A, B, ... are distributed by some other dimension, so is C.
%   
%   Example:
%   spmd
%       N1 = 500;
%       N2 = 1000;
%       D1 = codistributed.ones(N1,N2);
%       D2 = codistributed.zeros(N1,N2);
%       D3 = cat(1,D1,D2) % D3 is 1000-by-1000
%       D4 = cat(2,D1,D2) % D4 is 500-by-2000
%   end
%   
%   See also CAT, VERTCAT, HORZCAT, CODISTRIBUTED, CODISTRIBUTED/ONES, 
%   CODISTRIBUTED/ZEROS.


%   Copyright 2006-2016 The MathWorks, Inc.

distributedutil.CodistParser.verifyNonCodistributedInputs([{catdim}, varargin]);

catdim = distributedutil.CodistParser.gatherIfCodistributed(catdim);
if ~isscalar(catdim) || ~isPositiveIntegerValuedNumeric(catdim)
    error(message('MATLAB:catenate:invalidDimension'))
end

argList = varargin;
arrayIsCodist = cellfun(@(x) isa(x, 'codistributed'), argList);
if ~any( arrayIsCodist )
    % Must have got here with a codistributed catdim. Short-circuit with a call
    % to default cat. This might error if the arguments to be concatenated
    % are inconsistent.
    C = cat(catdim, argList{:});
    return
end

% The order of checks is important and must match the MATLAB
% dispatching rules to some degree:
% 1. First check if concatenating sparse arrays over dim > 2.
% 2. Then we can remove all 0-by-0 arrays because both cell and
%    non-cell concatenation handles them as no-ops.
% 3. Finally, verify that we don't have left a mixture of cells and
%    non-cells.
iVerifySparseOk(catdim, argList);

try
    templ = iGetTemplateForResult(argList);
catch err
    throw(err)
end

sizesCell = cellfun(@size, argList, 'UniformOutput', false);
[targetSize, szsInCatDim, isSquareEmpty] = iCalcSizes(sizesCell, catdim);
% We keep track of the 0-by-0 arrays as they:
% - Help determine the output class and attributes (captured in templ).
% - Determine the output when there are only 0-by-0 matrices in the
%   concatenation.

if all(isSquareEmpty)
    % Concatenating 0-by-0 arrays results in 0-by-0 if dim is 1 or 2, but 
    % 0-by-0-by-1-by-...1-by-length(argList) if dim > 2.
    X = distributedutil.Allocator.create(targetSize, templ);
    C = codistributed.pConstructFromReplicated(X); %#ok<DCUNK>
    return;
elseif all(isSquareEmpty(arrayIsCodist))
    % Only the non-codistributed arrays are not square empty.
    argList(arrayIsCodist) = [];
    X = distributedutil.Allocator.create(targetSize, templ);
    X(:) = cat(catdim, argList{:});
    if issparse(templ)
        X = sparse(X);
    end
    C = codistributed.pConstructFromReplicated(X); %#ok<DCUNK>
    return;
end

% The square empty arrays do not have any effect on the concatenation beyond
% this point other than we must use templ as the template element for the local
% part of the result.
argList(isSquareEmpty) = [];
arrayIsCodist(isSquareEmpty) = [];
szsInCatDim(isSquareEmpty) = [];

iVerifyCellLimitations(argList);

% Unpack the codistributors and local parts.  Let the codistributors
% be empty when the input array is replicated.
codists = cell(length(argList), 1);
LPs = cell(length(argList), 1);
codists(arrayIsCodist) = cellfun(@(x) getCodistributor(x), ...
                                 argList(arrayIsCodist), ...
                                'UniformOutput', false);
LPs(arrayIsCodist) = cellfun(@(x) getLocalPart(x), ...
                             argList(arrayIsCodist), ...
                             'UniformOutput', false);
LPs(~arrayIsCodist) = argList(~arrayIsCodist);


% If all of the codistributors are of the same class, call hCatCheck on one of
% them and then hCatImpl if it supports it.  Otherwise, use Redistributor.

codist1 = codists{find(arrayIsCodist, 1)};
isSameClass = cellfun(@(c) isa(c, class(codist1)), codists(arrayIsCodist));
canBeDoneByCodistributor = all(isSameClass) ...
    && codist1.hCatCheck(catdim, codists, LPs);
if canBeDoneByCodistributor
    [LPC, cDist] = codist1.hCatImpl(catdim, codists, LPs, templ, targetSize);
else
    [LPC, cDist] = distributedutil.Redistributor.catImpl(catdim, codists, LPs, ...
                                                      targetSize, szsInCatDim, templ);
end

C = codistributed.pDoBuildFromLocalPart(LPC, cDist); %#ok<DCUNK>
end % End of cat.

function iVerifySparseOk(catdim, argList)
% Throw an error if the concatenation involves invalid sparse
% concatenation.
    isSparse = any(cellfun(@issparse, argList));
    if catdim > 2 && any(isSparse)
        % Same error message as in base MATLAB.
        ex = MException(message('MATLAB:catenate:sparseDimensionBad'));
        throwAsCaller(ex);
    end

    if any(isSparse) && ~all(cellfun(@iIsDoubleOrLogical, argList))
        % Sparse array concatenated with anything else is a sparse array,
        % but we only support sparse double or logical arrays.  We can
        % therefore not concatenate, say, a sparse array with a single
        % array as that would result in a sparse single array.
        ex = MException(message('parallel:distributed:CatOnlySparseDouble'));
        throwAsCaller(ex);
    end
end % End of iVerifySparseOk.

function iVerifyCellLimitations(argList)
% Even though Base MATLAB can handle some of these, throw an error if
% the concatenation involves any mixture of cell arrays and non-cell
% arrays.
    isCellFcn = @(x) (isa(x, 'codistributed') ...
                      && isaUnderlying(x, 'cell')) || isa(x, 'cell');
    isCell = cellfun(isCellFcn, argList);
    if any(isCell) && ~all(isCell)
        ex = MException(message('parallel:distributed:CatNotSupportedCellMix'));
        throwAsCaller(ex);
    end
end % End of iVerifyCellLimitations.

function tf = iIsDoubleOrLogical(x)
    tf = ismember( distributedutil.CodistParser.class(x), {'double', 'logical'} );
end % End of iIsDoubleOrLogical.

function templ = iGetTemplateForResult(argList)
    templ = cell(size(argList));
    for i = 1:length(argList)
        currTempl = distributedutil.Allocator.extractTemplate(argList{i});
        if isempty(argList{i})
            templ{i} = distributedutil.Allocator.create([0, 0], currTempl);
        else
            templ{i} = distributedutil.Allocator.create([1, 1], currTempl);
        end
    end
    
    % Additional check for datetimes + strings: only allow concatenation if
    % the string is scalar.
    if any(cellfun(@isdatetime, argList)) && any(cellfun(@isstring, argList))
        % Check that all string inputs are scalar
        if any(cellfun( @(x) isstring(x) && ~isscalar(x), argList ))
            error(message('MATLAB:datetime:cat:InvalidConcatenation'));
        end
    end

    % Need to allocate space for the local parts, in particular we need to
    % determine what type should it be.  We use built-in cat to resolve the
    % types.  This may throw an error (e.g. if concatenating struct arrays with
    % different field names), but it would throw an error uniformly on all the
    % labs.
    templ = cat(1, templ{:});
    
end % End of iGetTemplateForResult.

function [targetSize, szsInCatDim, isSquareEmpty] = iCalcSizes(sizesCell, catdim)
% Calculate the size of the resulting array, and verify that the dimensions
% are consistent.  The returned szsInCatDim is the size of all of the input
% arrays in the concatenation dimension, and isSquareEmpty is a boolean
% vector whose i'th element is true iff the i-th array is a 0-by-0 array.
    nd = cellfun(@length, sizesCell);
    ndimsC = max([catdim, max(nd)]);
    allSizes = ones(length(sizesCell), ndimsC);
    for i = 1:length(sizesCell)
        allSizes(i, 1:nd(i)) = sizesCell{i};
    end
    szsInCatDim = allSizes(:, catdim);

    isSquareEmpty = cellfun(@(x) isequal(x, [0, 0]), sizesCell);
    
    targetSize = matlab.bigdata.internal.util.computeCatSize(catdim, sizesCell);
end
