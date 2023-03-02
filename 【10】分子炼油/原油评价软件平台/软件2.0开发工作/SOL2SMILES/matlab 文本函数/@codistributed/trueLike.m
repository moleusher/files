function D = trueLike(varargin)
%TRUELIKE True codistributed array matrix
%   
%   When P is of type codistributed array:
%   D = TRUELIKE(P,N) is an N-by-N codistributed matrix of logical ones.
%   This is equivalent to 
%   D = TRUE(N,'like',P)
%   P must be of logical underlying class.
%   
%   See also TRUE, CODISTRIBUTED, CODISTRIBUTED/true.


%   Copyright 2013 The MathWorks, Inc.

    D = codistributed.pBuildFromLikeFcn(@true, varargin{:}); %#ok<DCUNK>
end
