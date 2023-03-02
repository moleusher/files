function A = repmat(A, varargin)
%REPMAT Replicate and tile a codistributed array
%   B = repmat(A,M,N) creates a large codistributed array B consisting of an M-by-N
%   tiling of copies of A. The size of B is [size(A,1)*M, size(A,2)*N].  
%   
%   B = repmat(A,N) creates an N-by-N tiling.
%   B = repmat(A,[M N]) accomplishes the same result as repmat(A,M,N).
%    
%   B = repmat(A,[M N P ...]) tiles the codistributed array A to produce a 
%   multidimensional codistributed array B composed of copies of A. The size of B is 
%   [size(A,1)*M, size(A,2)*N, size(A,3)*P, ...].
%   
%   B = repmat(A,M,N,P,...) accomplishes the same result as B = repmat(A,[M N P ...]).
%    
%   Example:
%   spmd
%       A = codistributed.rand(10);
%       B = repmat( A, 200, 300 );
%       size(B) % B is a 2000 x 3000 array of tiled copies of A
%   end 
%   
%   See also REPMAT, CODISTRIBUTED, CODISTRIBUTED/RAND.

    
%   Copyright 2011-2016 The MathWorks, Inc.
    
    narginchk(2, Inf);
    
    distributedutil.CodistParser.verifyNonCodistributedInputs([{A}, varargin]);
    allowNegativeSizes = true;
    complexErrId = 'MATLAB:repmat:complexReplications';
    sizesVec = distributedutil.CodistParser.parseArraySizes( ...
        varargin, 'repmat', ...
        allowNegativeSizes, complexErrId);
    
    if ~isa(A, 'codistributed')
        A = repmat(A, sizesVec);
        return;
    end

    % We will do some calculation based on size, so make sure we have doubles    
    sizesVec = double(sizesVec);
    
    codistr = getCodistributor(A);
    
    % Work out what the final partition would be and check that the local
    % parts are allowed.
    outCodistr = iGetOutputCodistr(codistr, sizesVec);
    locSize = outCodistr.hLocalSize();
    [~,maxnumel] = computer();
    if prod(locSize) > maxnumel
        error(message('MATLAB:pmaxsize'));
    end
    
    zerosFcn = @iGetEmpty;
    catDimOrderingFcn = @codistr.hGetRepmatCatDimensionOrdering;
    A = parallel.internal.array.repmatImpl(A, sizesVec, zerosFcn, ...
        catDimOrderingFcn);
end

function A = iGetEmpty(A, outSz)
    % Helper for producing a codistributed zeros array of the specified size
    codistrA = iGetOutputCodistr( getCodistributor(A), outSz );
    A = codistributed.zeros(outSz, classUnderlying(A), codistrA);
end

function outCodistr = iGetOutputCodistr(inCodistr, outSz)
    % Create a new codistributor capable of storing the output
    if ~inCodistr.hSupportsDimensionality(length(outSz))
        [maxSz, maxDim] = max(outSz);
        outCodistr = codistributor1d(maxDim, ...
            codistributor1d.defaultPartition(maxSz), outSz);
    else
        outCodistr = inCodistr.hGetNewForSize(outSz);
    end
end

