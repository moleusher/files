function varargout = qr(varargin)
%QR Orthogonal-triangular decomposition for codistributed matrix
%   [Q,R] = QR(D)
%   [Q,R] = QR(D,0)
%   [Q,R,E] = QR(D) or equivalently [Q,R,E] = QR(D,'matrix')
%   [Q,R,e] = QR(D,0) or equivalently [Q,R,e] = QR(D,'vector')
%   
%   D must be a full codistributed matrix of floating point numbers (single or double).
%   Sparse arrays are not supported.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       [Q,R] = qr(D);
%       norm(Q*R-D,'inf')
%   end
%   
%   See also QR, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2010-2016 The MathWorks, Inc.

    narginchk(1, 3);
    nargoutchk(0, 3);

    distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);

    A = varargin{1};
    argList = distributedutil.CodistParser.gatherElements(varargin(2:end));
    if ~isa(A, 'codistributed')
        [varargout{1:nargout}] = qr(A, argList{:});
        return;
    end

    if issparse(A)
        error(message('parallel:distributed:QrUnsupportedSparse'));
    end

    if nargin == 3
        error(message('parallel:distributed:QrFullTooManyInputs'));
    end

    if nargout < 2
        error(message('parallel:distributed:QrTooFewOutputs'));
    end

    if nargin == 2
        isValidFlag = (isnumeric(argList{1}) && argList{1} == 0) || ...
            (ischar(argList{1}) && any(strcmpi(argList{1}, {'vector', 'matrix'})));
        if ~isValidFlag
            error(message('parallel:distributed:QrUnsupportedFlag'));
        end
    else
        argList{1} = 'matrix';
    end

    if ~isaUnderlying(A,'float') || ~ismatrix(A)
        error(message('parallel:distributed:QrNotFloat'));
    end

    if isempty(A)
        [varargout{1:nargout}] = iQrEmpty(A, argList{:});
    else
        [varargout{1:nargout}] = scalaQr(A, argList{:});
    end
end

function varargout = iQrEmpty(A, flag)
%iQrEmpty Produce appropriate outputs in case input was empty
%   Inputs: A - the input matrix
%           flag - flag that was passed or 'matrix' if none
%   Output: Q, R, (E)
    distA = getCodistributor(A);
    typeA = classUnderlying(A);
    [mA, nA] = size(A);
    if nA == 0 && isnumeric(flag)
        innerDim = 0;
    else
        innerDim = mA;
    end
    codistr = distA.hGetNewForSize([mA, innerDim]);
    varargout{1} = eye(mA, innerDim, typeA, codistr);
    codistr = distA.hGetNewForSize([innerDim, nA]);
    varargout{2} = zeros(innerDim, nA, typeA, codistr);
    if nargout == 3  % want pivots
        if strcmpi(flag, 'matrix')
            codistr = distA.hGetNewForSize([nA, nA]);
            varargout{3} = eye(nA, typeA, codistr);
        else
            codistr = distA.hGetNewForSize([1, nA]);
            varargout{3} = colon(1, nA, codistr);
        end
    end
end
