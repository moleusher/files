function varargout = subsref(A,aidx)
%SUBSREF Subscripted reference for codistributed array
%   B = A(I)
%   B = A(I,J)
%   B = A(I,J,K,...)
%   
%   The index I in A(I) must be :, scalar or a vector.
%   
%   A{...} indexing is not supported for codistributed cell arrays.
%   A.field indexing is not supported for codistributed arrays of structs.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.eye(N);
%       one = D(N,N)
%   end
%   
%   See also SUBSREF, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2016 The MathWorks, Inc.

% This method needs to have varargout so that users see the correct error
% message when trying to use struct indexing on a distributed array.

% We only support a single level of indexing for now, except for tables.
if ~istable(A) && length(aidx) ~= 1
    error(message('parallel:distributed:DistributedSubsrefSimple'))
end

% For multi-level indexing, only the final level can have more
% than one output.
try
    for ii=1:numel(aidx)-1
        A = iDispatchOne(A, aidx(ii));
    end
    [varargout{1:nargout}] = iDispatchOne(A, aidx(end));
catch err
    % Hide the call stack
    throw(err);
end

end

function varargout = iDispatchOne(A, S)
% Perform one level of indexing

% Different underlying types have different indexing capabilities
switch classUnderlying(A)
    case 'table'
        % Table indexing. Defer to specific implementation.
        % Tables only produce one output, even for brace indexing.
        if nargout>1
            error(message('MATLAB:TooManyOutputs'));
        end
        % To avoid stalls, make sure errors are thrown collectively
        varargout{1} = distributedutil.syncOnError(@iTableSubsref, A, S);
    otherwise
        % General array indexing. Only () supported.
        if ~isequal(S(1).type,'()')
            error(message('parallel:distributed:SubsrefBadIndexType'))
        end
        varargout{1} = iSubsrefParens(A, S);
end

end % subsref


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = iTableSubsref(A, aidx)
% Dispatch various indexing forms for tables

switch aidx(1).type
    case '()'
        % Table in, table out: just use normal indexing.
        varargout{1} = iTableSubsrefParens(A, aidx);
    case '{}'
        varargout{1} = iTableSubsrefBraces(A, aidx);
    case '.'
        varargout{1} = iTableSubsrefDot(A, aidx);
    otherwise
        error(message('MATLAB:subsTypeMustBeSquigglyOrSmooth'));
end

end % iTableSubsref

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iCheckTableIndexBounds(A, aidx)
% Throw table-specific errors for bad indices. Note that table checks index
% 2 before index 1!

% If using var-name specifier check names later
if ~iscell(aidx.subs)
    return
end

if numel(aidx.subs)~=2
    error(message('MATLAB:table:NDSubscript'));
end

% Var index must be numeric, logical or char (either ':' or a varname)
idx = aidx.subs{2};
if isnumeric(idx)
    if any(idx(:) < 1) 
        error(message('MATLAB:badsubscript',getString(message('MATLAB:badsubscriptTextRange'))));
    elseif any(idx(:) > width(A))
        error(message('MATLAB:table:VarIndexOutOfRange'));
    end
    
elseif islogical(idx)
    if numel(idx) > width(A)
        error(message('MATLAB:table:VarIndexOutOfRange'));
    end
    
elseif ischar(idx) || iscellstr(idx)
    % OK - could be ':' or list of varnames
    
else
    error(message('MATLAB:table:InvalidVarSubscript'));

end

% Row index should be numeric, logical or char (':')
idx = aidx.subs{1};
if isnumeric(idx)
    if any(idx(:) > height(A))
        error(message('MATLAB:table:RowIndexOutOfRange'));
    elseif any(idx(:) < 1) || any(idx(:) ~= round(idx(:)))
        error(message('MATLAB:badsubscript',getString(message('MATLAB:badsubscriptTextRange'))));
    end
    
elseif islogical(idx)
    if numel(idx) > height(A)
        error(message('MATLAB:table:RowIndexOutOfRange'));
    end
    
elseif matlab.bigdata.internal.util.isColonSubscript(idx)
    % OK
    
else
    error(message('MATLAB:table:InvalidRowSubscript'));
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dot indexing for distributed tables.
% Tables allow:
% * t.Properties - returns a special struct
% * t.X - returns the variable named X as a normal array
% * t.(n) - returns the nth variable
function out = iTableSubsrefDot(A, aidx)
varNames = iGetTableVariableNames(A);
if ischar(aidx.subs)
    aidx.subs = {aidx.subs};
end
if isequal(aidx.subs{1}, 'Properties')
    rowName = getString(message('MATLAB:table:uistrings:DfltRowDimName'));
    varName = getString(message('MATLAB:table:uistrings:DfltVarDimName'));
    out = struct('Description', {''}, ...
                 'UserData', {[]}, ...
                 'DimensionNames', {{rowName, varName}}, ...
                 'VariableNames', {varNames}, ...
                 'VariableDescriptions', {{}}, ...
                 'VariableUnits', {{}}, ...
                 'RowNames', {{}});
else
    varIdx = iResolveDotSubscript(aidx.subs{1}, varNames);
    
    % Extract the variable from the table
    out = iTableSubsrefBraces(A, substruct('{}', {':', varIdx}), varNames);
end
end % iTableSubsrefDot

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Paren indexing for distributed tables.
% Examples:
% * t(:,3)   - returns a new table with the third variable
% * t(3:4,2) - returns a new table with part of the second variable
% * t(:,2:3) - returns a new table with variables 2 and 3
% * t(:,'x') - returns a new table with variable 'x'
function out = iTableSubsrefParens(A, aidx, varNames)
if numel(aidx(1).subs) ~= 2
    error(message('MATLAB:table:NDSubscript'));
end
if nargin<3
    varNames = iGetTableVariableNames(A);
end
[~, aidx.subs{2}] = distributedutil.lookupTableVars(aidx.subs{2}, varNames);

% Table throws slightly different errors for bad indices.
iCheckTableIndexBounds(A, aidx);

% Now that we have numeric indices we can just call standard subsrefParen
out = iSubsrefParens(A, aidx);

end % iTableSubsrefParens

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Brace indexing for distributed tables.
% Examples:
% * t{:,3} - returns the contents of the third variable
% * t{3:4,2} - returns part of the second variable
% * t{:,2:3} - returns variables 2 and 3 concatenated
% * t{:,'x'} - returns the contents of variable 'x'
%
% NB: varNames is an optional list of the variable names if they are
% already known (to avoid calculating them twice).
function out = iTableSubsrefBraces(A, aidx, varNames)
if numel(aidx(1).subs) ~= 2
    error(message('MATLAB:table:NDSubscript'));
end
if nargin<3
    varNames = iGetTableVariableNames(A);
end
[firstSub, secondSub] = deal(aidx.subs{:});
[~, secondSubNumeric] = distributedutil.lookupTableVars(secondSub, varNames);

% Table throws slightly different errors for bad indices.
iCheckTableIndexBounds(A, aidx);

% We can now use smooth parens to select the region of interest and then
% table2array on the local parts to convert into contiguous form.
psub = substruct('()', {firstSub secondSubNumeric});
tableOut = iSubsrefParens(A, psub);
outLP = table2array(getLocalPart(tableOut));
outCodistr = getCodistributor(tableOut);
distDim = outCodistr.Dimension;

% Note that whilst the table itself is always 2D with width equal to the
% number of variables, the data inside can be ND, resulting in ND output.
% We must build a new codistributor. The sizes of each local part must
% match except in the distribution dimension.
if distDim==2
    % With variables spread across workers, each local part may have a
    % different type. Work out the overall output type using concatenation
    % of all non-empty partitions.
    tmpl = getTableTemplate(tableOut);
    tmplArr = table2array(tmpl);
    
    % Need special care for empty outputs as they must still be the right
    % type
    if isempty(outLP)
        % ... take care for tables inside tables...
        if istable(tmplArr) && ~istable(outLP)
            % This worker does not take part in the resulting table. Need
            % to create an empty table with the right number of rows.
            outLP = array2table(outLP);
        else
            % Need an empty of the right type. Just resize the template.
            outLP = reshape(tmplArr, size(outLP));
        end
    else
        % If not empty, concatenation will get us the type without further
        % communication.
        outLP = [tmplArr([],[]), outLP];
    end
    % Work out the output size based on all columns in the template (i.e.
    % from all workers), but set the rows to size of the local part.
    globalSize = size(tmplArr);
    globalSize(1) = size(outLP,1);
    % Get the new partitioning by asking all workers their size
    part = gcat(size(outLP, distDim));
    
else
    % When distributed in first dimension, we already know the partition
    % and just need to know the new trailing dimensions.
    part = outCodistr.Partition;
    globalSize = size(outLP);
    globalSize(distDim) = sum(part);
end

outCodistr = codistributor1d(distDim, part, globalSize);
out = codistributed.pDoBuildFromLocalPart(outLP , outCodistr); %#ok<DCUNK> Calling a private static method.
end % iTableSubsrefBraces

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Retrieve the list of Variables
function varNames = iGetTableVariableNames(A)
% Use a helper to get a template table no matter how it was originally
% distributed.
tmpl = getTableTemplate(A);
varNames = tmpl.Properties.VariableNames;
end % iGetTableVariableNames

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Resolve a variable subscript into an index
function varIdx = iResolveDotSubscript(subscript, varNames)

% For cases tt.Foo and equivalently tt.('Foo'), we allow the subscript to be
% only: scalar string, char-vector, and numeric integer scalar.

% Handle scalar strings by converting to char.
if isstring(subscript) && isscalar(subscript)
    subscript = char(subscript);
end

if ischar(subscript) || ...
        (isnumeric(subscript) && isscalar(subscript) && round(subscript) == subscript)
    
    if parallel.internal.indexing.isColonLiteral(subscript)
        error(message('MATLAB:table:UnrecognizedVarName', subscript));
    else
        % Resolve numeric integer scalars or char-vectors against
        % known variable names, re-use resolveVarNameSubscript.
        [~,varIdx] = distributedutil.lookupTableVars(subscript, varNames);
        assert(isscalar(varIdx), ...
            'Unexpectedly resolved dot-subscript to multiple variables.');
    end
else
    error(message('MATLAB:table:IllegalVarSubscript'));
end

end % iGetTableVariableNames

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function B = iSubsrefParens(A, aidx)
% Standard implementation of paren, i.e. (), indexing.
nargoutchk(0, 1);

% This implementation only supports codistributor1d.
codistributed.pVerifyUsing1d('subsref', A); %#ok<DCUNK> private static

% The index is always replicated.
aidx = iGatherIndex(aidx);

% For a single index that is colon-literal, just reshape
if numel(aidx(1).subs)==1 && parallel.internal.indexing.isColonLiteral(aidx(1).subs{1})
    B = colonize(A);
    
    % For a single index which is not a vector use
    %   B = reshape(A(idx(:)), size(idx))
    % until such time as we can work out a better scheme.
elseif numel(aidx(1).subs)==1 && ~isvector(aidx(1).subs{1})
    outDims = size(aidx(1).subs{1});
    aidx(1).subs{1} = aidx(1).subs{1}(:);
    
    B = subsrefImpl(A,aidx);
    
    B = reshape(B, outDims);
else
    % Normal vector indexing
    B = subsrefImpl(A,aidx);
end

end % iParenSubsref


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function B = subsrefImpl(A,aidx)
% Actual implementation of subsref for vector index arguments
% B = A(:)
% B = A([1 2 3])
% B = A([1 2 3], [4 5 6], :)
% etc
%
% *but not*
% B = A([1 2;3 4])

% B = A(subs). Minimal communication between labs.
orgLengthSubs = length(aidx(1).subs);
[A, Aloc, aidx, partA, bDistDim, sizeb] = iPrepIndexAndCalcSizeOfB(A, aidx);

% If the result is going to be empty we can avoid most of the work for
% homogeneous arrays (i.e. not tables)
if prod(sizeb)==0 && ~istable(A)
    codistr = hGetNewForSize(getCodistributor(A), sizeb);
    Bloc = iMakeEmptyLocalPart(Aloc, aidx, codistr);
    B = codistributed.pDoBuildFromLocalPart(Bloc, codistr); %#ok<DCUNK>
    return;
end

% Error check subscripts in the distribution dimension here because all labs are
% still working with the replicated index.  This allows them all to throw an
% error at the same time.
subInBDistDim = aidx.subs{bDistDim};
% TODO: Fix this here.  We need to colonize the index in the distribution
% dimension when there are multiple indices.
if sum(size(subInBDistDim)~=1)>1
    error(message('parallel:distributed:SubsrefBadSubscriptSize'))
end

% We need to error check the index in the distribution dimension of B ourselves
% because we will manipulate it further on.  The builtin subsref will error
% check the indices in the other dimensions.
if ~isnumeric(subInBDistDim) || ...
        any(subInBDistDim(:)<=0) || any(~isfinite(subInBDistDim(:))) ...
        || any(subInBDistDim(:) ~= floor(subInBDistDim(:)))
    error(message('parallel:array:SubsrefInvalidSubscript'))
end

sizea = size(A);
% Let smax store the upper bound on the permissible index value.
smax = sizea;
smax(orgLengthSubs) = prod(smax(orgLengthSubs:end));
smax(end+1:bDistDim) = 1;
% TODO: Can this be simplified to any(subInBDistDim(:) > smax(bDistDim))?
if (orgLengthSubs == 1 && any(subInBDistDim(:) > smax(1))) ...
        || (orgLengthSubs > 1 && any(subInBDistDim(:) > smax(bDistDim)))
    error(message('parallel:array:SubsrefSubscriptExceedsDim'))
end

% Subscript ranges

% Calculate vectors of length numlabs storing the start and end indices of A in
% the distribution dimension that reside on each lab.
endA = cumsum(partA);
startA = endA - partA + 1;
% If the user used linear indexing, we have already colonized A.  If the user
% used > 1 index but < ndims(A) indices, we fold the last dimensions of A, so we
% have to update the start and end indices accordingly.
lengthsubs = length(aidx.subs);
% Note that at this point, lengthsubs is always > 1 as the output of
% iPrepIndexAndCalcSizeOfB.
foldLastDimensions = lengthsubs < length(sizea);
if foldLastDimensions
    strideInLastIndexDim = prod(sizea(lengthsubs:end-1));
    startA = strideInLastIndexDim*(startA-1)+1;
    endA = strideInLastIndexDim*endA;
end

% Determine partition of B so that little communication is required.

% Let the partition of B be such that each lab stores the same elements of A as
% it has.
% TODO: Figure out how this maps into the communicating subsref.
partB = zeros(1,numlabs);
for k = 1:numlabs
    partB(k) = sum((startA(k) <= subInBDistDim) & (subInBDistDim <= endA(k)));
end
endB = cumsum(partB);
startB = endB-partB+1;

% Check if no communication is required
% Determine q and r so that A(...,subInBDistDim(q),...) is on this lab and
% B(..., q(r),...)  is on this lab.

% Find all the subscripts into A in the dimension bDistDim that refer to values
% that we have on this lab.
q = find((startA(labindex) <= subInBDistDim) & (subInBDistDim <= endA(labindex)));
% Find those elements of q that will end up in elements of B that we store on
% this lab.
r = find((startB(labindex) <= q) & (q <= endB(labindex)));

if istable(A)
    % Tables are special as we must get the right variable names too. Note
    % that all workers must get here, even if all data stays on the worker
    % so we handle this case first.
    tmpl = getTableTemplate(A);
    % Get a template for the output table
    tmpl = subsref(tmpl, substruct('()', {':',aidx.subs{2}}));
    if bDistDim==2
        % If workers have different variables, sub-select only those for this worker
        tmpl = subsref(tmpl, substruct('()', {':',startB(labindex):endB(labindex)}));
    end
    sizeBloc = sizeb;
    sizeBloc(bDistDim) = partB(labindex);
    Bloc = distributedutil.Allocator.create(sizeBloc, tmpl);
    Bloc = iGetBlocWithCommunications(Aloc, Bloc, aidx, endA, startA, endB, startB, bDistDim, sizea);
    
elseif isinparfor
    % Does the indexing into my local part create all of B?  We ignore where it
    % should end up and put all of it here.
    if length(r) == sum(partB)
        aidx.subs{bDistDim} = subInBDistDim(q(r))-startA(labindex)+1;
        % Since we are inside a for-drange statement and are returning a regular MATLAB
        % array, we don't inspect or modify the sparsity of B.  Rather, we just
        % return what regular MATLAB indexing gives us.
        B = subsref(Aloc,aidx);
        return
    else
        error(message('parallel:distributed:SubsrefInparfor'))
    end
    
elseif length(r) == partB(labindex)
    % The indexing into my local part all ends up on this lab.  We therefore don't
    % need any message passing.
    aidx.subs{bDistDim} = subInBDistDim(q(r))-startA(labindex)+1;
    Bloc = subsref(Aloc,aidx);
    
else
    % General paren subsref
    sizea = size(A);
    sizeBloc = sizeb;
    sizeBloc(bDistDim) = partB(labindex);
    Bloc = distributedutil.Allocator.create(sizeBloc, Aloc);
    Bloc = iGetBlocWithCommunications(Aloc, Bloc, aidx, endA, startA, endB, startB, bDistDim, sizea);
end

% Result is a codistributed array
codistr = codistributor1d(bDistDim, partB, sizeb);
B = codistributed.pDoBuildFromLocalPart(Bloc, codistr); %#ok<DCUNK> Calling a private static method.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Bloc = iMakeEmptyLocalPart(Aloc, aidx, codistr)
% We can't use 'like' for non-numeric types, so instead use empty subsref
% to get a new (empty) local part of the right size. We form the
% subsref call Aloc([],:,:,...) with empties in dimensions that are to
% be set to zero, and colons elsewhere. This avoids things like RESHAPE
% which not all types support.
bsize = hLocalSize(codistr);
bDistDim = codistr.Dimension;
if bDistDim<=numel(bsize)
    sizeInDistDim = bsize(bDistDim);
else
    % Trailing sizes are treated as 1
    sizeInDistDim = 1;
end
% Make sure we don't request more than is there
sizeInDistDim = min(sizeInDistDim, size(Aloc,bDistDim));

% Create some indices into the local part. These will be the same as the
% global indices (aidx.subs) except in the distribution dimension.
bsubs = aidx.subs;
if bDistDim > numel(bsubs)
    % Pad the indices out to the distribution dimension
    for ii = numel(bsubs)+1 : bDistDim
        bsubs{ii} = 1;
    end
end

bsubs{bDistDim} = 1:sizeInDistDim;

Bloc = subsref(Aloc, substruct('()', bsubs));

end % iMakeEmptyLocalPart

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aidx = iGatherIndex(aidx)
for k = 1:length(aidx.subs)
    if isa(aidx.subs{k}, 'codistributed')
        aidx.subs{k} = gather(aidx.subs{k});
    end
    if islogical(aidx.subs{k})
        aidx.subs{k} = find(aidx.subs{k});
    end
end
end % End of iGatherIndex

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A, Aloc, aidx, partA, bDistDim, sizeb] = iPrepIndexAndCalcSizeOfB(A, aidx)
% Pre-process aidx and calculate the size of B as well as its distribution
% dimension.
% aidx is returned in a form such that aidx.subs is of length >= bDistDim.
lengthsubs = length(aidx.subs);
nda = ndims(A);
aDist = getCodistributor(A);
if lengthsubs > 1
    % More than one index used, e.g. A(X, Y), A(:, [1:10; 21:30], 5), etc.
    % 1) The number of indices may exceed ndims(A), but the extra indices better be
    % 1 or ':'.
    % 2) The number of indices may be less than ndims(A), in which case we fold the
    % last dimensions of A.
    % 3) The shape of the indices is ignored, and they are treated as the colonized
    % versions.
    %
    % We plan on letting B be distributed either across its last dimension, or
    % across aDist.Dimension.  The number of dimensions of B will equal the
    % number of indices used into A.
    sizea = size(A);
    if lengthsubs >= nda
        % There are at least as many indices as ndims(A).  The last "real" index
        % (i.e. those that aren't required to be equivalent to 1) is in the last
        % dimension of A.
        bDistDim = aDist.Dimension;
        % Ensure that aidx and sizea include the distribution dimension of A and B.
        sizea(end+1:aDist.Dimension) = 1;
        aidx.subs(end+1:aDist.Dimension) = {1};
        lengthsubs = length(aidx.subs);
        if parallel.internal.indexing.isColonLiteral(aidx.subs{bDistDim})
            aidx.subs{bDistDim} = 1:sizea(bDistDim); % Expand so we can divy up between labs.
        end
    else
        if aDist.Dimension ~= nda
            % Redistribute A so that the local parts are storing contiguous blocks of the
            % linear index of A.
            aDist = codistributor('1d',nda, codistributor1d.defaultPartition(sizea(nda)));
            A = redistribute(A, aDist);
            aDist = getCodistributor(A);
        end
        % At this point, A is distributed across its last dimension, but the last index
        % is in a dimension strictly less than that.
        bDistDim = lengthsubs;
        if parallel.internal.indexing.isColonLiteral(aidx.subs{bDistDim})
            aidx.subs{bDistDim} = 1:prod(sizea(bDistDim:end));
        end
    end
    % The shape of the indices does not matter since more than one index was
    % specified.  We therefore convert all indices into column vectors.
    for k = 1:lengthsubs
        if ~parallel.internal.indexing.isColonLiteral(aidx.subs{k})
            aidx.subs{k} = aidx.subs{k}(:);
        end
    end
    
    partA = aDist.Partition;
    Aloc = getLocalPart(A);
    % Figure out the global size of B.
    sizeb = zeros(1,lengthsubs);
    for k = 1:length(sizeb)
        if parallel.internal.indexing.isColonLiteral(aidx.subs{k})
            sizeb(k) = size(A,k);
        else
            sizeb(k) = length(aidx.subs{k});
        end
    end
else
    % Only one index used, i.e. linear indexing, such as A(1),
    % A([1:10; 21:30]), etc. Note that A(:) has already been taken care of.
    % When performing indexing with one input, i.e. A(X),, the output has the same
    % shape as the index matrix X, except when both A and X are vectors.  When
    % that is true, A(X) has the same shape as A, not X.
    sizea = size(A);
    sizeidx = size(aidx.subs{1});
    isAVectorNotScalar = iIsNDVector(A) && ~isscalar(A);
    isIdxVector = isvector(aidx.subs{1});
    
    % Abort early for empty (but non-vector) index
    if ~isIdxVector && prod(sizeidx)==0
        sizeb = sizeidx;
        Aloc = [];
        partA = [];
        bDistDim = [];
        return;
    end
    
    % Convert A into a distributed column vector.  Note that this may be extremely
    % inefficient: Colonize can result in an all-to-all communication, and this
    % we go this code path to retrieve a single element of A, such as, say, A(1).
    A = colonize(A);
    aDist = getCodistributor(A);
    Aloc = getLocalPart(A);
    partA = aDist.Partition;
    
    % The shape of B depends on whether A is a vector as well as how it is being
    % indexed.  If A and idx are both vectors, the shape of A is preserved.
    % If not, the shape of the index vector is preserved.
    preserveAShape = (isAVectorNotScalar && isIdxVector);
    
    if preserveAShape
        % Work out the output size. This should be the same as the size of A
        % but with the non-unity dimension replaced.
        bDistDim = iFirstNonSingletonDim(sizea);
        sizeb = ones(1,numel(sizea));
        sizeb(bDistDim) = prod(sizeidx);
    else
        % Shape comes from index vector. Scalar should be distributed along
        % second dimension to match default scheme, otherwise distribute
        % along the non-unity dimension.
        if isscalar(aidx.subs{1})
            bDistDim = 2;
        else
            bDistDim = iFirstNonSingletonDim(sizeidx);
        end
        sizeb = sizeidx;
    end
    
    
    % Now create a new subscript array with one subscript per output
    % dimension
    bsubs = aidx.subs{1};
    aidx.subs = repmat({1}, 1, numel(sizea));
    aidx.subs{bDistDim} = bsubs;
    
    % Reshape local part to the same shape as the output
    sizealoc = ones(1,numel(sizeb));
    sizealoc(bDistDim) = numel(Aloc);
    Aloc = reshape(Aloc, sizealoc);
end
end % End of iPrepIndexAndCalcSizeOfB.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Bloc = iGetBlocWithCommunications(Aloc, Bloc, aidx, endA, startA, endB, startB, bDistDim, sizea)

subInBDistDim = aidx.subs{bDistDim};
% Subscript structure for use with builtin subsref and subsasgn

bidx = substruct('()',repmat({':'}, 1, length(sizea)));

% Double loop over labs.  Determine q and r so that A(...,subInBDistDim(q(r)),...)
% is on lab srcLab and B(...,q(r),...) is on lab destLab.

mwTag = 32006;
for srcLab = 1:numlabs
    q = find((startA(srcLab) <= subInBDistDim) & (subInBDistDim <= endA(srcLab)));
    if ~isempty(q)
        for destLab = 1:numlabs
            r = find((startB(destLab) <= q) & (q <= endB(destLab)));
            if ~isempty(r)
                aidx.subs{bDistDim} = subInBDistDim(q(r)) - startA(srcLab) + 1;
                bidx.subs{bDistDim} = q(r) - startB(destLab) + 1;
                if destLab == srcLab && srcLab == labindex
                    Bloc = subsasgn(Bloc, bidx, subsref(Aloc, aidx));
                elseif srcLab == labindex
                    labSend(subsref(Aloc, aidx), destLab, mwTag)
                elseif destLab == labindex
                    Bloc = subsasgn(Bloc, bidx, labReceive(srcLab, mwTag));
                end
            end
        end
    end
end

end % End of iGetBlocWithCommunications.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isvec = iIsNDVector(data)
% Helper that returns true for any N-D vector. That is, any array where at
% most one dimension is not unity.
isvec = (sum(size(data)~=1) <= 1);
end % iIsNDVector


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dimIdx = iFirstNonSingletonDim(dims)
% Return the index of the first non-singleton dimension, or 1 if all unity.
dimIdx = find(dims~=1,1,'first');
if isempty(dimIdx)
    dimIdx = 1;
end
end % iFirstNonSingletonDim
