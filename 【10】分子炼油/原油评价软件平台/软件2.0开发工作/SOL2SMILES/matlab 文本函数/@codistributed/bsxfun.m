function A = bsxfun(fh, A, B)
%BSXFUN  Binary Singleton Expansion Function for codistributed array
%   C = BSXFUN(FUN,A,B) applies the element-by-element binary operation
%   specified by the function handle FUN to arrays A and B, with singleton
%   expansion enabled.
%   
%   The corresponding dimensions of A and B must be equal to each other, or 
%   equal to one. Whenever a dimension of A or B is singleton (equal to 
%   one), BSXFUN virtually replicates the array along that dimension to 
%   match the other array. In the case where a dimension of A or B is 
%   singleton and the corresponding dimension in the other array is zero,
%   BSXFUN virtually diminishes the singleton dimension to zero.
%    
%   The size of the output array C is equal to
%   max(size(A),size(B)).*(size(A)>0 & size(B)>0). For example, if
%   size(A) == [2 5 4] and size(B) == [2 1 4 3], then size(C) == [2 5 4 3].
%    
%   Examples:
%   %Subtract the column means from the matrix A:
%   
%   spmd
%       A = codistributed.rand(8);
%       A = bsxfun(@minus, A, mean(A));
%   end
%   
%   %Compute z(x, y) = x.*sin(y) on a grid:
%   spmd
%         x = codistributed.colon(1,10);
%         y = x.';
%         z = bsxfun(@(x, y) x.*sin(y), x, y);
%   end
%    
%   See also BSXFUN, CODISTRIBUTED, function_handle, gather


%   Copyright 2011-2015 The MathWorks, Inc.

    narginchk(3, 3);
    if ~isa(fh, 'function_handle')
        error(message('MATLAB:bsxfun:nonFunctionHandle'));
    end
    iCheckInputs(A, B);
    distributedutil.CodistParser.verifyNonCodistributedInputs({A, B});
    [LPA, LPB, codistr] = iGetCodistributorAndLocalParts(A, B);
    LPA = bsxfun(fh, LPA, LPB);
    A = codistributed.pDoBuildFromLocalPart(LPA, codistr); %#ok<DCUNK>
end

function tf = iIsScalarDouble(x)
clz = parallel.internal.array.typeof(x);
tf = isscalar(x) && isequal(clz, 'double');
end

function iCheckInputs(A, B)
    dimsA = size(A);
    dimsB = size(B);
    minSz = min(length(dimsA), length(dimsB));
    szA = dimsA(1:minSz);
    szB = dimsB(1:minSz);
    if ~all(szA == szB | szA == 1 | szB == 1)
        error(message('MATLAB:bsxfun:arrayDimensionsMustMatch'));
    end
end

function [LPA, LPB, codistr] = iGetCodistributorAndLocalParts(A, B)
    dimsA = size(A);
    dimsB = size(B);
    args = {A, B};

    % There's a wildcard in operation when there is precisely one scalar-double
    isSDA = iIsScalarDouble(A);
    isSDB = iIsScalarDouble(B);
    isWildcard = sum([isSDA; isSDB]) == 1;
    
    % Only redistribute here if there's no wildcard in operation.
    if isequal(dimsA, dimsB) && ~isWildcard
        [LP, codistr] = codistributed.pRedistSameSizeToSingleDist(args); %#ok<DCUNK>
        [LPA, LPB] = LP{:};
        return
    end
    ndimsA = ndims(A);
    ndimsB = ndims(B);
    sz = ones(2, max(ndimsA, ndimsB));
    sz(1, 1:ndimsA) = dimsA(1:ndimsA);
    sz(2, 1:ndimsB) = dimsB(1:ndimsB);
    outputSz = max(sz);
    
    % modify outputSz if one of the inputs was empty
    outputSz(min(sz) == 0) = 0;
    
    % determine output codistributor
    codistr = iGetOutputCodistributor(args, outputSz);
    
    % get local parts
    LPA = iGetLocalPart(codistr, A, isWildcard && isSDA);
    LPB = iGetLocalPart(codistr, B, isWildcard && isSDB);
end

function codistr = iGetOutputCodistributor(args, outputSz)
    isCodistr = cellfun(@iscodistributed, args, 'UniformOutput', true);
    codistrs = cellfun(@getCodistributor, args(isCodistr), 'UniformOutput', ...
        false);
    validCodistrs = cellfun(@(x)(x.hSupportsDimensionality(length(outputSz))), ...
        codistrs, 'UniformOutput', true);
    switch nnz(validCodistrs)
        case 0
            [maxSz, maxDim] = max(outputSz);
            codistr = codistributor1d(maxDim, ...
                codistributor1d.defaultPartition(maxSz), outputSz);
        case 1
            codistr = codistrs{validCodistrs};
            codistr = codistr.hGetNewForSize(outputSz);  %resize used codistributor
        case 2
            if numel(args{1})>=numel(args{2})
                codistr = codistrs{1};
            else
                codistr = codistrs{2};
            end
            codistr = codistr.hGetNewForSize(outputSz);  %resize used codistributor        
    end
end

function LP = iGetLocalPart(codistr, A, isThisArgWildcard)
    szA = size(A);
    
    % We must always gather args if they are the sole wildcard argument, as per
    % g1317175.
    if isThisArgWildcard || codistr.hDoGatherBsxfunInput(szA)
        replA = gather(A);
        LP = codistr.hGetBsxfunLocalPartFromReplicated(replA);
        return
    end
   
    % Here if gathering is unnecessary - redistribute
    destCodistr = codistr.hGetCompleteForSize(szA);
    if iscodistributed(A)
        codistrA = getCodistributor(A);
        LPA = getLocalPart(A);
        LP = distributedutil.Redistributor.redistribute(codistrA, LPA, ...
            destCodistr);
    else
        LP = destCodistr.hBuildFromReplicatedImpl(0, A);
    end
end
