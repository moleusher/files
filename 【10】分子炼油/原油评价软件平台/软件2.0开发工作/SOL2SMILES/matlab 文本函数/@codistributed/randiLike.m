function D = randiLike(varargin)
%RANDILIKE randiLike codistributed array 
%   
%   When P is of type codistributed array:
%   D = RANDILIKE(P,N) is an N-by-N codistributed matrix of psuedo-random integer
%   values with the same underlying class as P. This is equivalent to 
%   D = RANDI(N,'like',P)
%   
%   P must be of numeric underlying class.
%   
%   See also RANDI, CODISTRIBUTED, CODISTRIBUTED/randi.


%   Copyright 2013 The MathWorks, Inc.

    D = codistributed.pBuildFromLikeFcn(@randi, varargin{:}); %#ok<DCUNK>
end
