function D = false(varargin)
%CODISTRIBUTED.FALSE False codistributed array
%   D = CODISTRIBUTED.FALSE(N) is an N-by-N codistributed matrix 
%   of logical zeros, distributed using the default distribution scheme.
%   
%   D = CODISTRIBUTED.FALSE(M,N) is an M-by-N codistributed matrix
%   of logical zeros.
%   
%   D = CODISTRIBUTED.FALSE(M,N,K, ...) or CODISTRIBUTED.FALSE([M,N,K, ...])
%   is an M-by-N-by-K-by-... codistributed array of logical zeros.
%   
%   Optional arguments to CODISTRIBUTED.FALSE must be specified after the
%   size arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   D = FALSE(...,'like',P) for a CODISTRIBUTED argument P returns an codistributed array of logical zeros
%   of the requested size. P must be of logical underlying class.
%   If CODISTR is not supplied as an optional argument, D will have the same
%   codistributor as P.
%   
%   Example:
%   spmd
%       N  = 1000;
%       D1 = codistributed.false(N); % 1000-by-1000 false codistributed array
%       D2 = codistributed.false(N, 2*N); % 1000-by-2000
%       D3 = codistributed.false([N, 2*N]); % 1000-by-2000
%       D4 = false(N,'like',D3); % 1000-by-1000 false codistributed array
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D5 = codistributed.false(N, codistributor('1d', 1));
%       % Using 2D block-cyclic codistributor.
%       D6 = false(N, codistributor2dbc(), 'noCommunication', 'like', D5);
%   end
%   
%   See also FALSE, CODISTRIBUTED, CODISTRIBUTED/TRUE, CODISTRIBUTED/ZEROS,
%   CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2008-2013 The MathWorks, Inc.

D = codistributed.pBuildFromFcn(@false, varargin{:});
