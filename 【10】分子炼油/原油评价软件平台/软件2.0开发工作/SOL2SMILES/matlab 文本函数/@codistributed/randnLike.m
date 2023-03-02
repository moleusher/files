function D = randnLike(varargin)
%RANDNLIKE randnLike codistributed array 
%   
%   When P is of type codistributed array:
%   D = RANDNLIKE(P,N) is an N-by-N codistributed matrix of normally ditributed 
%   psuedo-random values with the same underlying class as P. This is 
%   equivalent to D = RANDN(N,'like',P)
%   
%   P must be of numeric underlying class.
%   
%   See also RANDN, CODISTRIBUTED, CODISTRIBUTED/randn.


%   Copyright 2013 The MathWorks, Inc.

    D = codistributed.pBuildFromLikeFcn(@randn, varargin{:}); %#ok<DCUNK>
end
