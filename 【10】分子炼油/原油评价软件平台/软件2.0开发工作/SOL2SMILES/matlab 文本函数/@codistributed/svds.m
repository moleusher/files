function varargout = svds(varargin)
%SVDS   Find a few largest singular values and vectors of a codistributed matrix.
%   S = SVDS(A)
%   S = SVDS(A,K)
%   S = SVDS(A,K,'largest')
%   S = SVDS(A,K,'largest',OPTIONS)
%       with OPTIONS.tol
%            OPTIONS.maxit
%            OPTIONS.p
%   
%   [U,S,V] = SVDS(A,...)
%   [U,S,V,FLAG] = SVDS(A,...)
%   
%   The following syntaxes are not supported for codistributed array:
%   [...] = SVDS(A,K,'smallest')
%   [...] = SVDS(A,K,'smallestnz')
%   [...] = SVDS(A,K,'largest',OPTIONS)
%           with OPTIONS.v0/u0
%   
%   Example:
%   spmd
%       A = codistributed(gallery('neumann',100));
%       sl = SVDS(A,10)
%   end
%   
%   A must be double matrix. Both real and
%   complex types are supported.
%   
%   
%   See also SVD, EIGS, CODISTRIBUTED, CODISTRIBUTED/SVD, CODISTRIBUTED/EIG.


%   Copyright 2010-2016 The MathWorks, Inc.

% This function only works for 1d distributions
codistributed.pVerifyUsing1d('svds',varargin{1}); %#ok<DCUNK>

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.svds(varargin{:});
catch ME
    throw(ME);
end