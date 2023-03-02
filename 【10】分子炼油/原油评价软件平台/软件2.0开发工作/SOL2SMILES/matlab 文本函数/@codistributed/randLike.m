function D = randLike(varargin)
%RANDLIKE randLike codistributed array 
%   
%   When P is of type codistributed array:
%   D = RANDLIKE(P,N) is an N-by-N codistributed matrix of psuedo-random values with
%   the same underlying class as P. This is equivalent to 
%   D = RAND(N,'like',P)
%   
%   P must be of numeric underlying class.
%   
%   See also RAND, CODISTRIBUTED, CODISTRIBUTED/rand.


%   Copyright 2013 The MathWorks, Inc.

    D = codistributed.pBuildFromLikeFcn(@rand, varargin{:}); %#ok<DCUNK>
end
