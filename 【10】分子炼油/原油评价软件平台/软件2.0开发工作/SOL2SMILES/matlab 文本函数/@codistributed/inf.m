function D = inf(varargin)
%CODISTRIBUTED.INF Infinity codistributed array
%   D = CODISTRIBUTED.INF(N) is an N-by-N codistributed matrix of INFs.
%   
%   D = CODISTRIBUTED.INF(M,N) is an M-by-N codistributed matrix of INFs.
%   
%   D = CODISTRIBUTED.INF(M,N,K,...) or CODISTRIBUTED.INF([M,N,K,...])
%   is an M-by-N-by-K-by-... codistributed array of INFs.
%   
%   D = CODISTRIBUTED.INF(M,N,K,..., CLASSNAME) or 
%   CODISTRIBUTED.INF([M,N,K,...], CLASSNAME) is an M-by-N-by-K-by-... 
%   codistributed array of INFs of class specified by CLASSNAME.  CLASSNAME 
%   must be either 'single' or 'double'.
%   
%   Other optional arguments to CODISTRIBUTED.INF must be specified after the
%   size and class arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   D = INF(...,'like',P) for a CODISTRIBUTED argument P returns a codistributed array of INFs of the 
%   same complexity as P and the requested size. If CLASSNAME is not specified then D has 
%   the same underlying class as P. P must have underlying class 'single' or 'double'.
%   If CODISTR is not supplied as an optional argument, D will have the same
%   codistributor as P.
%   
%   As shown in the example, all forms of the built-in function have been 
%   overloaded for codistributed arrays.
%   
%   Example:
%   % Create a 1000-by-1 codistributed array of underlying class 'single' 
%   % containing the value Inf:
%   spmd
%       N = 1000;
%       D1 = codistributed.inf(N, 1,'single');
%       % D2 is a 1000-by-1000 codistributed array with the same underlying class
%       D2 = inf(N,'like',D1); 
%       D3 = codistributed.Inf(1, N);
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D4 = codistributed.Inf(N, codistributor('1d', 1));
%       % Using 2D block-cyclic codistributor.
%       D5 = Inf(N, 'single', codistributor2dbc(), 'noCommunication', 'like', D4);
%   end
%   
%   See also INF, CODISTRIBUTED, CODISTRIBUTED/ZEROS, CODISTRIBUTED/ONES,
%   CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2008-2013 The MathWorks, Inc.

D = codistributed.pBuildFromFcn(@inf, varargin{:});
