function varargout = chol(varargin)
%CHOL Cholesky factorization of codistributed array
%   R = CHOL(D)
%   [R,p] = CHOL(D)
%   L = CHOL(D, 'lower')
%   [L,p] = CHOL(D, 'lower')
%   
%   D must be a full codistributed matrix of floating point numbers (single or double).
%   Sparse arrays are not supported. The 'vector' option is not supported.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 1 + codistributed.eye(N);
%       [R,p] = chol(D);
%       isequal(p, 0) % true
%       norm(R'*R - D, 1)
%   end
%   
%   See also CHOL, CODISTRIBUTED, CODISTRIBUTED/EYE.


%   Copyright 2006-2013 The MathWorks, Inc.

narginchk(1, 2);
nargoutchk(0, 2);

distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);

A = varargin{1};
argList = distributedutil.CodistParser.gatherElements(varargin(2:end));
if ~isa(A, 'codistributed')
    [varargout{1:nargout}] = chol(A, argList{:});
    return;
end

if ~isaUnderlying(A,'float') || ~ismatrix(A) || issparse(A)
    error(message('parallel:distributed:CholNotSupported'));
end
if size(A,1) ~= size(A,2)
    error(message('parallel:distributed:CholSquare'));
end

if nargin == 1  % Upper factorization is default
    argList{1} = 'upper';
end
    
if ~any(strcmpi(argList{1},{'upper', 'lower'}))
    error(message('parallel:distributed:CholInputType'));
end

[A, p]=scalaChol(A, argList{:});
   
if p > 0
    if nargout <= 1
        error(message('parallel:distributed:CholPosdef'));
    else
       indx.type = '()';
       indx.subs = {1:p-1, 1:p-1};
       A = subsref(A, indx);
    end
end
varargout{1} = A;
if nargout >= 2
    varargout{2} = p;
end

