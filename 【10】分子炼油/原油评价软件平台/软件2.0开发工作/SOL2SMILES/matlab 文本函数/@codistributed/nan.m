function D = nan(varargin)
%CODISTRIBUTED.NAN Build codistributed array containing Not-a-Number
%   D = CODISTRIBUTED.NAN(N) is an N-by-N codistributed matrix of NANs.
%   
%   D = CODISTRIBUTED.NAN(M,N) is an M-by-N codistributed matrix of NANs.
%   
%   D = CODISTRIBUTED.NAN(M,N,K,...) or CODISTRIBUTED.NAN([M,N,K,...])
%   is an M-by-N-by-K-by-... codistributed array of NANs.
%   
%   D = CODISTRIBUTED.NAN(M,N,K,..., CLASSNAME) or 
%   CODISTRIBUTED.NAN([M,N,K,...], CLASSNAME) is an M-by-N-by-K-by-... 
%   codistributed array of NANs of class specified by CLASSNAME.  CLASSNAME
%   must be either 'single' or 'double'.
%   
%   Other optional arguments to CODISTRIBUTED.NAN must be specified after the
%   size and class arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   D = NAN(...,'like',P) for a CODISTRIBUTED argument P returns a codistributed array of NANs of the 
%   same complexity as P. If CLASSNAME is not specified then D has the same underlying class
%   as P. P must have underlying class 'single' or 'double'.
%   If CODISTR is not supplied as an optional argument, D will have the same
%   codistributor as P.
%   
%   As shown in the example, all forms of the built-in function have been 
%   overloaded for codistributed arrays.
%   
%   Example:
%   spmd
%       N = 1000;
%       % Create a 1000-by-1 codistributed array of underlying class 'single'
%       % containing the value NaN.
%       D1 = codistributed.nan(N, 1,'single');
%       % D2 is a 1000-by-1000 codistributed array with the same underlying class
%       D2 = NaN(N,'like',D1); 
%       D3 = codistributed.NaN(1, N);
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D4 = codistributed.nan(N, codistributor('1d', 1));
%       % Using 2D block-cyclic codistributor:
%       D5 = NaN(N, 'single', codistributor2dbc(), 'noCommunication', 'like', D4);
%   end
%   
%   See also NAN, CODISTRIBUTED, CODISTRIBUTED/ZEROS, CODISTRIBUTED/ONES,
%   CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2008-2013 The MathWorks, Inc.

D = codistributed.pBuildFromFcn(@nan, varargin{:});
