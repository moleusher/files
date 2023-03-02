function C = conv2(varargin)
%CONV2 Two dimensional convolution of codistributed arrays.
%   C = CONV2(A, B)
%   C = CONV2(H1, H2, A)
%   C = CONV2(..., SHAPE)
%   
%   A, B, H1, H2 must be numeric or logical arrays. Both real and complex types are supported.
%   H1 and H2 must not be codistributed arrays.
%   
%   Example:
%   spmd
%            N = 500;
%            A = codistributed.ones(2*N, N);
%            B = codistributed.rand(N);
%            C = conv2(A, B);
%   end
%   
%   See also CONV2, CODISTRIBUTED, CODISTRIBUTED/CONV, CODISTRIBUTED/FILTER2.
%   
%   


%   Copyright 2010-2016 The MathWorks, Inc.

narginchk(2,4);

% CONV2 can be called with either two vectors and a matrix or two matrices.
% Work out which.
numDataArgs = nargin;
if ischar(varargin{end})
    numDataArgs = numDataArgs - 1;
end
switch numDataArgs
    case 1
        % Tried to call conv2(data,char)
        error(message('MATLAB:conv2:inputType'));
    case 2
        % C = conv2(A,B)
        C = iConv2NonSep(varargin{:});
    case 3
        % C = conv2(h1,h2,A)
        C = iConv2Sep(varargin{:});
    otherwise
        % Tried to pass data for shape parameter
        error(message('MATLAB:conv2:unknownShapeParameter'));
end
end

function C = iConv2Sep(hrow,hcol,A,varargin)
% Perform 2D convolution using separated vectors and a matrix

% Handle both C = conv2(hrow,hcol,A) and C = conv2(hrow,hcol,A,shape)
% For this case we require that only A is distributed. HROW and HCOL must
% be replicated.

% HROW and HCOL must be vectors or empty 2D
if (~isvector(hrow) && ~isempty(hrow)) || ~ismatrix(hrow)...
        || (~isvector(hcol) && ~isempty(hcol)) || ~ismatrix(hcol)
    error(message('MATLAB:conv2:firstTwoInputsNotVectors'))
end
if ~ismatrix(A)
    error(message('parallel:distributed:Conv2AorBNotMatrix'))
end

% Check the shape argument (if any)
[isSame, isValid] = convShapeCheck('MATLAB:conv2:unknownShapeParameter', varargin{:});

% Check that only A is codistributed
if iscodistributed(hrow) || iscodistributed(hcol)
    error(message('parallel:distributed:Conv2HrowHcolCodistributed'))
end
% We know that hrow, hcol and shape are not codistributed, so A must be
assert(iCheckDistribution(A));

if issparse(hrow) || issparse(hcol) || issparse(A)
    error(message('parallel:distributed:InvalidSparse','conv2'));
end

% Logical and all intgers are transformed to double.
errorMsg = 'MATLAB:conv2:inputTypeSeparable';
hrow = ensureFloatingPoint(hrow, errorMsg);
hcol = ensureFloatingPoint(hcol, errorMsg);
A = ensureFloatingPoint(A, errorMsg);

% Pack hrow and hcol into a structure B and use the shared implementation
B = struct( ...
    'hrow', hrow, ...
    'hcol', hcol );
szB = [length(hrow),length(hcol)];
outClass = superiorfloat(A,hrow,hcol);

% Guard against empty results
if isempty(A) || isempty(hrow) || isempty(hcol)
    C = iHandleEmptyCase(size(A),szB,isValid,isSame,outClass);
    return;
end

C = convDistRepl(A,B,@conv2,outClass);

% Maybe trim the result
C = convTrimResult(C, size(A), szB, isSame, isValid);
end

function C = iConv2NonSep(A,B,varargin)
% Perform 2D convolution of two matrices

% Handle both C = conv2(A,B) and C = conv2(A,B,shape)

if ~ismatrix(A) || ~ismatrix(B)
    error(message('parallel:distributed:Conv2AorBNotMatrix'))
end

% Check the shape argument (if any)
[isSame, isValid] = convShapeCheck('MATLAB:conv2:unknownShapeParameter', varargin{:});

% This function only works for 1d distributions
isCodA = iCheckDistribution(A);
isCodB = iCheckDistribution(B);

if issparse(A) || issparse(B)
    error(message('parallel:distributed:InvalidSparse','conv2'));
end

% Logical and all intgers are transformed to double.
errorMsg = 'MATLAB:conv2:inputType';
A = ensureFloatingPoint(A, errorMsg);
B = ensureFloatingPoint(B, errorMsg);

outClass = superiorfloat(A,B);

% If any of the inputs is empty, the answer is either empty or zeros
if isempty(A) || isempty(B)
    C = iHandleEmptyCase(size(A),size(B),isValid,isSame,outClass);
    return;
end

if isCodA && ~isCodB
    C = convDistRepl(A,B,@conv2,outClass);
else
    if isCodB && ~isCodA
        C = convDistRepl(B,A,@conv2,outClass);
    else
        assert(isCodA && isCodB)
        C = convDistDist(A,B,@conv2,outClass);
    end
end

% Maybe trim the result
C = convTrimResult(C,size(A),size(B),isSame,isValid);
end

function C = iHandleEmptyCase(szA,szB,isValid,isSame,outClass)
% Handle the case where one or both of them is empty

if isValid
    szResult = szA - max(szB,[1 1]) + [1 1];
elseif isSame
    szResult = szA;
else
    offset = -1 * (szA ~= 0 & szB ~= 0);
    szResult = szA + szB + offset;
end
C = codistributed.zeros(szResult,outClass);

end

function isCodA = iCheckDistribution(A)
% Check for distribution, and ensure that 
% 1d distribution is used

isCodA = iscodistributed(A);
if isCodA
    codistributed.pVerifyUsing1d('conv2',A); %#ok<DCUNK>
end
end