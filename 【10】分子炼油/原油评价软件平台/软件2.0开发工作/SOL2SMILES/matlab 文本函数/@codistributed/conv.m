function C = conv(A,B,varargin)
%CONV Convolution and polynomial multiplication of codistributed arrays.
%   C = CONV(A, B)
%   C = CONV(A, B, SHAPE)
%   
%   A and B must be numeric or logical arrays. Both real and complex types are supported. 
%   
%   Example:
%   spmd
%            N = 1000;
%            A = codistributed.ones(N, 1);
%            B = codistributed.rand(2*N,1);
%            C = conv(A, B);
%   end
%    
%   See also CONV, CODISTRIBUTED, CODISTRIBUTED/CONV2, CODISTRIBUTED/FILTER.
%   
%   


%   Copyright 2010-2016 The MathWorks, Inc.

if ~isvector(A) || ~isvector(B)
    error(message('MATLAB:conv:AorBNotVector'));
end

narginchk(2,3);

% Default is full convolution
[isSame, isValid] = convShapeCheck('MATLAB:conv:unknownShapeParameter', varargin{:});
isFull = ~isSame && ~isValid;

% This function only works for 1d distributions
isCodA = iCheckDistribution(A);
isCodB = iCheckDistribution(B);

if issparse(A) || issparse(B)
    error(message('parallel:distributed:InvalidSparse','conv'));
end

% Logical and all intgers are transformed to double.
errorMsg = 'MATLAB:conv2:inputType';
A = ensureFloatingPoint(A, errorMsg);
B = ensureFloatingPoint(B, errorMsg);

outClass = superiorfloat(A,B);

% If any of the inputs is empty, the answer is either empty or zeros
emptA = isempty(A);
emptB = isempty(B);
if emptA || emptB
    C = iHandleEmptyCase(A,B,emptA,isValid,isSame,outClass);
    return;
end

% If the valid part is required and kernel is larger, the answer is empty
if isValid && (numel(B) > numel(A))
    if isrow(A)
        szResult = [1, 0];
    else
        szResult = [0, 1];
    end
    C = codistributed.zeros(szResult,outClass);
    return;
end

% If either input is scalar, we must use TIMES instead
if isscalar(A) || isscalar(B)
    C = iHandleScalarCase(A,B,isSame);
    return;
end

% Boolean variable which tells us if the output should be a row(true) or a
% column(false)
isResultRow = ( isrow(A) && (numel(A) > numel(B) || ~isFull) ) || ...
    ( isrow(B) && (numel(B) >= numel(A) && isFull) );

if isCodA && ~isCodB
    C = convDistRepl(A,B,@conv,outClass,isResultRow);
else
    if isCodB && ~isCodA
        C = convDistRepl(B,A,@conv,outClass,isResultRow);
    else
        assert(isCodA && isCodB)
        C = convDistDist(A,B,@conv,outClass,isResultRow);
    end
end

[szA,szB] = iReshapeSizes(isResultRow, size(A),size(B));
C = convTrimResult(C,szA,szB,isSame,isValid);
end

function flag = iCheckDistribution(A)
% Check for distribution, and ensure that 
% 1d distribution is used

flag = iscodistributed(A);
if flag
    codistributed.pVerifyUsing1d('conv',A); %#ok<DCUNK>
end
end

function C = iHandleEmptyCase(A,B,emptA,isValid,isSame,outClass)
% Handle the case where one or both of them is empty

if emptA
    if isValid || isSame
        szResult = size(A);
    else
        szResult = size(B);
    end
else
    % B is empty. Just use size of A.
    szResult = size(A);
end
C = codistributed.zeros(szResult,outClass);
end

function C = iHandleScalarCase(A,B,isSame)
% Handle the case where one or both of them is scalar - this must fall back
% on being an element-wise TIMES to avoid problems with NaN.

C = A.*B;

% If using 'full' or 'valid' we are done. For 'same' we might need to
% extract one element.
if isSame && ~isscalar(B)
    idx = floor(numel(C)/2)+1;
    C = subsref(C, struct('type','()','subs',{{idx}}));
end
end

function [szA,szB] = iReshapeSizes(isResultRow,szA,szB)
% Return the correct-shaped sizes to convTrimResult

if isResultRow
    szA = sort(szA,'ascend');
    szB = sort(szB,'ascend');
else
    szA = sort(szA,'descend');
    szB = sort(szB,'descend');
end
end