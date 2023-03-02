function D = true(varargin)
%CODISTRIBUTED.TRUE True codistributed array
%   D = CODISTRIBUTED.TRUE(N) is an N-by-N codistributed matrix 
%   of logical ones.
%   
%   D = CODISTRIBUTED.TRUE(M,N) is an M-by-N codistributed matrix
%   of logical ones.
%   
%   D = CODISTRIBUTED.TRUE(M,N,K, ...) or CODISTRIBUTED.TRUE([M,N,K, ...])
%   is an M-by-N-by-K-by-... codistributed array of logical ones.
%   
%   Optional arguments to CODISTRIBUTED.TRUE must be specified after the
%   size arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   D = TRUE(...,'like',P) for a CODISTRIBUTED argument P returns a codistributed array of logical ones
%   of the requested size. P must be of logical underlying class.
%   If CODISTR is not supplied as an optional argument, D will have the same
%   codistributor as P.
%   
%   Examples:
%   spmd
%       N  = 1000;
%       D1 = codistributed.true(N); % 1000-by-1000 true logical codistributed array
%       D2 = codistributed.true(N, N*2); % 1000-by-2000
%       D3 = codistributed.true([N, N*2]); % 1000-by-2000
%       D4 = true(N,'like',D3); % 1000-by-1000 true codistributed array
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D5 = codistributed.true(N, codistributor('1d', 1));
%       % Using 2D block-cyclic codistributor:
%       D6 = true(N, codistributor2dbc(), 'noCommunication', 'like', D5);
%   end
%   
%   See also TRUE, CODISTRIBUTED, CODISTRIBUTED/FALSE, CODISTRIBUTED/ONES,
%   CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2008-2013 The MathWorks, Inc.

D = codistributed.pBuildFromFcn(@true, varargin{:});
