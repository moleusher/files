function A = reshape(A, varargin)
%RESHAPE Change size of codistributed array
%   RESHAPE(G,M,N) returns the M-by-N codistributed whose elements are 
%   taken columnwise from G. An error results if G does not 
%   have M*N elements.
%   
%   RESHAPE(G,M,N,P,...) returns an N-D array with the same
%   elements as G but reshaped to have the size M-by-N-by-P-by-...
%   M*N*P*... must be the same as PROD(SIZE(G)).
%   
%   RESHAPE(G,[M N P ...]) is the same thing.
%   
%   RESHAPE(G,...,[],...) calculates the length of the dimension
%   represented by [], such that the product of the dimensions 
%   equals PROD(SIZE(G)). PROD(SIZE(G)) must be evenly divisible 
%   by the product of the known dimensions. You can use only one 
%   occurrence of [].
%   
%   In general, RESHAPE(G,SIZ) returns an N-D array with the same
%   elements as G but reshaped to the size SIZ.  PROD(SIZ) must be
%   the same as PROD(SIZE(G)). 
%   
%   
%   Example:
%   spmd
%       x = codistributed.colon(1,1000);
%       y = reshape(x,10,10,10)
%   end
%   
%   See also RESHAPE, CODISTRIBUTED, CODISTRIBUTED/COLON.


%   Copyright 2008-2012 The MathWorks, Inc.

distributedutil.CodistParser.verifyNonCodistributedInputs([{A}, varargin]);
argList = distributedutil.CodistParser.gatherElements(varargin);
if ~isa(A, 'codistributed')
    A = reshape(A, argList{:});
    return;
end

LPA = getLocalPart(A);
codistrA = getCodistributor(A);
newSz = iParseSizeArguments(codistrA.Cached.GlobalSize, argList);
newSz = distributedutil.Sizes.removeTrailingOnes(newSz);
if isequal(newSz, codistrA.Cached.GlobalSize)
    % Nothing to do.
    return;
end

clear A;
if codistrA.hReshapeCheck(newSz) 
    % We can do reshape without communication
    [LPA, codistrA] = codistrA.hReshapeImpl(LPA, newSz);
else
    [LPA, codistrA] = distributedutil.Redistributor.reshapeImpl(codistrA, ...
        LPA, newSz);
end
A = codistributed.pDoBuildFromLocalPart(LPA, codistrA); %#ok<DCUNK>

end % End of reshape.

function desiredSize = iParseSizeArguments(orgSize, argList)
% Convert the size inputs to reshape into a single vector of sizes.  Throw an
% error as caller on invalid input.
    
orgNumel = prod(orgSize);
try
    if isscalar(argList)
        % Size is specified as a single size vector.
        if ~isrow(argList{1})
            % Error message matches base MATLAB.
            error(message('parallel:distributed:ReshapeRowSize'));
        end
        desiredSize = arrayfun(@iConvToDim, argList{1});
    else
        % Size is specified as a list of scalars or [].
        desiredSize = cellfun(@iConvToDim, argList);
        desiredSize = iCalculateUnspecifiedSize(orgNumel, desiredSize);
    end
catch E
    throwAsCaller(E); % Strip off the stack, including this function.
end

% We now know that desiredSize contains non-negative flints, but we don't know
% whether we can reshape the array to that size.
if length(desiredSize) < 2 
    % Error message matches the one in base MATLAB.
    ex = MException(message('parallel:distributed:ReshapeTwoElements'));
    throwAsCaller(ex);
elseif prod(desiredSize) ~= orgNumel
    % Error message matches the one in base MATLAB.
    ex = MException(message('parallel:distributed:ReshapeSameNumel'));
    throwAsCaller(ex);
end

end % End of iParseSizeArguments.

function x = iConvToDim(v)
% Convert a single, scalar input argument to a dimension, or throw an error.
allowZeros = true;  % Allow 0 because array might be empty.
if isempty(v) 
    % Leave as -1 for iCalculateUnspecifiedSize to replace with correct value.
    x = -1; 
elseif isscalar(v) && isPositiveIntegerValuedNumeric(v, allowZeros)
    x = double(v);
else
    error(message('parallel:distributed:ReshapeNonnegativeSize'));
end    
end % End of iConvToDim.

function desiredSize = iCalculateUnspecifiedSize(orgNumel, desiredSize)
% Fill in the unspecified element in desiredSize, if any, or throw an error.
unspecIdx = desiredSize < 0;
numUnspecified = nnz(unspecIdx);
if numUnspecified > 1
    % Error message matches the one in base MATLAB.
    error(message('parallel:distributed:ReshapeOneUnknownDim'));
elseif numUnspecified == 1
    knownProduct = prod(desiredSize(~unspecIdx)); 
    if knownProduct == 0
        % We arbitrarily choose 0 for the unspecified value.  If orgNumel is 0,
        % this is a sensible choice, but otherwise we will error because
        % the reshape operation would change the number of elements in the
        % array.
        unspecValue = 0;
    else
        unspecValue = orgNumel / knownProduct;
        if unspecValue ~= round(unspecValue)
            % Error message matches the one in base MATLAB.
            error(message('parallel:distributed:ReshapeNotDivisible', orgNumel, knownProduct));
        end
    end
    desiredSize(unspecIdx) = unspecValue;
end
end % End of iCalculateUnspecifiedSize.
