function D = randi(varargin)
%CODISTRIBUTED.RANDI Create a codistributed array of random integers
%   
%   D = CODISTRIBUTED.RANDI(IMAX, N) returns an N-by-N codistributed array containing
%   pseudorandom integer values drawn from the discrete uniform distribution on
%   1:IMAX, distributed using the default distribution scheme.
%   
%   D = CODISTRIBUTED.RANDI(IMAX,M,N) or D = CODISTRIBUTED.RANDI(IMAX,[M,N]) returns an M-by-N
%   codistributed array. D = CODISTRIBUTED.RANDI(IMAX,M,N,P,...) or D =
%   CODISTRIBUTED.RANDI(IMAX,[M,N,P,...])  returns an M-by-N-by-P-... codistributed array.
%   
%   D = CODISTRIBUTED.RANDI([IMIN, IMAX], ...) returns a codistributed array containing integer
%   values drawn from the discrete uniform distribution on IMIN:IMAX.
%   
%   D = CODISTRIBUTED.RANDI(..., CLASSNAME) returns a codistributed array with underlying class
%   CLASSNAME.
%   
%   D = RANDI(...,'like',P) for a codistributed argument P returns a 
%   codistributed array of pseudorandom integer values with the same underlying 
%   class as P.
%   
%   D = CODISTRIBUTED.RANDI(..., CODISTR) is a codistributed array of
%   pseudorandom integer values, distributed using the codistributor CODISTR.
%   CODISTR must be specified after the size and class arguments.
%   
%   D = CODISTRIBUTED.RANDI(..., CODISTR, 'noCommunication') is a codistributed
%   array of pseudorandom integer values, created in the manner specified
%   above.  However, no communication when constructing the array, so some
%   error checking steps are skipped.  CODISTR must be complete, as can be
%   checked by calling CODISTR.ISCOMPLETE().
%   
%   Examples:
%   spmd
%       % Generate random integers from the uniform distribution on the set 1:10:
%       D1 = codistributed.randi(10, 1, 100)
%       % Generate a codistributed array containing random integers from -10:10 
%       % of underlying class 'int32':
%       D2 = codistributed.randi([-10 10], 1, 100, 'int32')
%       D3 = randi([-10 10], 1, 100, 'like', D2); % underlying class 'int32'
%   end
%   
%   See also RANDI, CODISTRIBUTED, CODISTRIBUTED.BUILD, CODISTRIBUTOR.


%   Copyright 2008-2013 The MathWorks, Inc.

D = codistributed.pBuildFromFcn(@randi, varargin{:});
