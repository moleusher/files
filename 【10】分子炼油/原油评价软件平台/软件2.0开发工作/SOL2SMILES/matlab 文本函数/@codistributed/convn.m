function C = convn(varargin)
%CONVN N-dimensional convolution of codistributed arrays.
%   C = CONVN(A, B)
%   C = CONVN(A, B, SHAPE)
%   
%   A and B must be numeric or logical arrays. Both real and complex types are supported.
%   
%   Example:
%   spmd
%       N = 1000;
%       A = codistributed.rand(2*N, N, 3);
%       B = codistributed.rand(3, 3, 2);
%       C = convn(A, B);
%   end
%   
%   See also CONV, CONVN, CODISTRIBUTED, CODISTRIBUTED/CONV, CODISTRIBUTED/CONVN, CODISTRIBUTED/FILTER2.


%   Copyright 2012-2016 The MathWorks, Inc.

narginchk(2,3);

numDataArgs = nargin;
if ischar(varargin{end})
    numDataArgs = numDataArgs - 1;
end
switch numDataArgs
    case 1
        % Tried to call convn(data,char)
        error(message('MATLAB:convnc:inputType'));
    case 2
        % C = convn(A,B)
        C = iConvn(varargin{:});
    otherwise
        % Tried to pass data for shape parameter
        error(message('MATLAB:convnc:UnsupportedDataType'));
end
end

% Perform ND convolution of two matrices
function C = iConvn(A,B,varargin)
% Handle both C = convn(A,B) and C = convn(A,B,shape)

% Check the shape argument (if any)
[isSame, isValid] = convShapeCheck('MATLAB:convnc:UnsupportedDataType', varargin{:});

if issparse(A) || issparse(B)
    error(message('parallel:distributed:InvalidSparse','convn'));
end

% This function only works for 1d distributions
isCodA = iCheckDistribution(A);
isCodB = iCheckDistribution(B);

% Logical and all intgers are transformed to double.
errorMsg = 'MATLAB:convnc:inputType';
A = ensureFloatingPoint(A, errorMsg);
B = ensureFloatingPoint(B, errorMsg);

outClass = superiorfloat(A,B);

% If any of the inputs is empty, the answer is either empty or zeros
if isempty(A) || isempty(B)
    C = iHandleEmptyCase(A,B,isValid,isSame,outClass);
    return;
end

if isCodA && ~isCodB
    C = convDistRepl(A,B,@convn,outClass);
else
    if isCodB && ~isCodA
        C = convDistRepl(B,A,@convn,outClass);
    else
        assert(isCodA && isCodB)
        C = convDistDist(A,B,@convn,outClass);
    end
end

% Maybe trim the result
paddedSzA = [size(A) ones(1,ndims(C)-ndims(A))];
paddedSzB = [size(B) ones(1,ndims(C)-ndims(B))];

C = convTrimResult(C,paddedSzA,paddedSzB,isSame,isValid);
end

function C = iHandleEmptyCase(A,B,isValid,isSame,outClass)
% Handle the case where one or both of them is empty

% szA and szB have the same number of elements
szA = [size(A) ones(1,ndims(B) - ndims(A))];
szB = [size(B) ones(1,ndims(A) - ndims(B))];

if isValid
    szResult = szA - max(szB,ones(1,length(szB))) + ones(1,length(szB));
elseif isSame
    szResult = szA;
else
    offset = -1 * (szA ~= 0 & szB ~= 0);
    szResult = szA + szB + offset;
end
C = codistributed.zeros(szResult,outClass);
end

function flag = iCheckDistribution(A)
% Check for distribution, and ensure that 
% 1d distribution is used

flag = iscodistributed(A);
if flag
    codistributed.pVerifyUsing1d('conv',A); %#ok<DCUNK>
end
end