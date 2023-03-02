function varargout = lu(varargin)
%LU LU factorization for codistributed array
%   [L,U,P] = LU(D, 'vector')
%   
%   D must be a full codistributed matrix of floating point numbers (single or double).
%   
%   The following syntaxes are not supported for full codistributed D:
%   [...] = LU(D)
%   [...] = LU(D,'matrix')
%   X = LU(D,'vector')
%   [L,U] = LU(D,'vector')
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       [L,U,piv] = lu(D,'vector');
%       norm(L*U-D(piv,:), 1)
%   end
%   
%   See also LU, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2012 The MathWorks, Inc.

narginchk(1, 2);

distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);

A = varargin{1};
argList = distributedutil.CodistParser.gatherElements(varargin(2:end));
if ~isa(A, 'codistributed')
    [varargout{1:nargout}] = lu(A, argList{:});
    return;
end

if nargout ~= 3 || nargin < 2 || ~strcmpi(argList{1}, 'vector')
   error(message('parallel:distributed:LuSupported'));
end


if ~isaUnderlying(A,'float') || ~ismatrix(A) || issparse(A)
    error(message('parallel:distributed:LuNotFloat'));
end

[varargout{1:nargout}]=scalaLu(A);
