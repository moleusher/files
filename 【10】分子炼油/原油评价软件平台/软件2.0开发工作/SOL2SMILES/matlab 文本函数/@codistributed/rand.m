function D = rand(varargin)
%CODISTRIBUTED.RAND codistributed array of uniformly distributed pseudorandom numbers
%   D = CODISTRIBUTED.RAND(N) is an N-by-N codistributed matrix of uniformly 
%   distributed pseudorandom numbers.
%   
%   D = CODISTRIBUTED.RAND(M,N) is an M-by-N codistributed matrix
%   of uniformly distributed pseudorandom numbers.
%   
%   D = CODISTRIBUTED.RAND(M,N,P, ...) or CODISTRIBUTED.RAND([M,N,P, ...])
%   is an M-by-N-by-P-by-... codistributed array of uniformly distributed
%   pseudorandom numbers.
%   
%   D = CODISTRIBUTED.RAND(M,N,P,..., CLASSNAME) or 
%   CODISTRIBUTED.RAND([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   codistributed array of uniformly distributed pseudorandom numbers of class 
%   specified by CLASSNAME.
%   
%   D = RAND(...,'like',P) for a codistributed argument P returns a 
%   codistributed array of uniformly distributed pseudorandom numbers with the 
%   same underlying class as P.
%   
%   Other optional arguments to CODISTRIBUTED.RAND must be specified after the
%   size and class arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   Examples:
%   spmd
%       N  = 1000;
%       D1 = codistributed.rand(N) % 1000-by-1000 codistributed array of rand
%       D2 = codistributed.rand(N, N*2) % 1000-by-2000
%       D3 = codistributed.rand([N, N*2], 'single') % underlying class 'single'
%       D4 = rand([N, N*2], 'like', D3); % underlying class 'single'
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D4 = codistributed.rand(N, codistributor('1d', 1))
%       % Using 2D block-cyclic codistributor.
%       D5 = codistributed.rand(N, codistributor('2dbc'), 'noCommunication')
%   end
%   
%   See also RAND, CODISTRIBUTED, CODISTRIBUTED/ZEROS, CODISTRIBUTED/ONES,
%   CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2008-2013 The MathWorks, Inc.

D = codistributed.pBuildFromFcn(@rand, varargin{:});
