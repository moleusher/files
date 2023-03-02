function varargout = svd(varargin)
%SVD Singular value decomposition of codistributed matrix
%   If A is square, S = SVD(A) returns the singular values of A, and 
%   [U,S,V] = SVD(A) returns the singular value decomposition of A.
%   
%   If A is rectangular, you must specify "economy size" decomposition.
%   [U,S,V] = SVD(A,'econ')
%   
%   [U,S,V] = SVD(A, 0) is not supported.
%       
%   Example:
%   % Compute a real square matrix A, its singular values S, and singular
%   % vectors U and V such that A*V is within round-off error of U*S.
%   spmd
%       N = 1000;
%       A = codistributed.rand(N);
%       [U,S,V] = svd(A);
%       norm(A*V-U*S,1)
%   end
%   
%   
%   See also SVD, CODISTRIBUTED, CODISTRIBUTED/RAND.
%   


%   Copyright 2006-2012 The MathWorks, Inc.

narginchk(1, 2);
nargoutchk(0, 3);

distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);

A = varargin{1};
argList = distributedutil.CodistParser.gatherElements(varargin(2:end));
if ~isa(A, 'codistributed')
    [varargout{1:nargout}] = svd(A, argList{:});
    return;
end

if ~isaUnderlying(A, 'float') || ~ismatrix(A) || issparse(A)
    error(message('parallel:distributed:SvdNotFloat'));
end

switch nargin
  case 1
    if (nargout > 1 ) && ( size(A,1) ~= size(A,2) )
        error(message('parallel:distributed:SvdOnlyEconomySvd'));
    end
  case 2
    isValidOptArg = @(x)( ischar(x) && strcmpi(x, 'econ') );
    if ~isValidOptArg( argList{1} )
        error(message('parallel:distributed:SvdUnknownOptionForEconSizeDecomp'));
    end
end

[varargout{1:nargout}]=scalaSvd(A);
