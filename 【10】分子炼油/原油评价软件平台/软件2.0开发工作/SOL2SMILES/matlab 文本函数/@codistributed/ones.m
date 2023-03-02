function D = ones(varargin)
%CODISTRIBUTED.ONES Ones codistributed array
%   D = CODISTRIBUTED.ONES(N) is an N-by-N codistributed matrix of ones.
%   
%   D = CODISTRIBUTED.ONES(M,N) is an M-by-N codistributed matrix of ones.
%   
%   D = CODISTRIBUTED.ONES(M,N,K,...) or CODISTRIBUTED.ONES([M,N,K,...])
%   is an M-by-N-by-K-by-... codistributed array of ones.
%   
%   D = CODISTRIBUTED.ONES(M,N,K,..., CLASSNAME) or 
%   CODISTRIBUTED.ONES([M,N,K,...], CLASSNAME) is an M-by-N-by-K-by-... 
%   codistributed array of ones of class specified by CLASSNAME.
%   
%   Other optional arguments to CODISTRIBUTED.ONES must be specified after the
%   size and class arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   D = ONES(...,'like',P) for a CODISTRIBUTED argument P returns a codistributed array of ones of the same
%   complexity as P and the requested size. If CLASSNAME is not specified then D has the same
%   underlying class as P. P must be of numeric or logical underlying class.
%   If CODISTR is not supplied as an optional argument, D will have the same
%   codistributor as P.
%   
%   Examples:
%   spmd
%       N  = 1000;
%       D1 = codistributed.ones(N);   % 1000-by-1000 codistributed matrix of ones
%       D2 = codistributed.ones(N,N*2); % 1000-by-2000
%       D3 = codistributed.ones([N,N*2], 'int8'); % underlying class 'int8'
%       D4 = ones(N,'like',D3) % 1000-by-1000 codistributed array with underlying class 'int8'
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D5 = codistributed.ones(N, codistributor('1d', 1));
%       % Using 2D block-cyclic codistributor:
%       D6 = ones(N, 'single', codistributor2dbc(), 'noCommunication', 'like', D5);
%   end
%   
%   See also ONES, CODISTRIBUTED, CODISTRIBUTED/ZEROS, CODISTRIBUTED/BUILD,
%   CODISTRIBUTOR.


%   Copyright 2008-2015 The MathWorks, Inc.

D = codistributed.pBuildFromFcn(@ones, varargin{:});
