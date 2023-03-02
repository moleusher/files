function D = falseLike(varargin)
%FALSELIKE False codistributed array matrix
%   
%   When P is of type codistributed array:
%   D = FALSELIKE(P,N) is an N-by-N codistributed matrix of logical zeros.
%   This is equivalent to 
%   D = FALSE(N,'like',P)
%   P must be of logical underlying class.
%   
%   See also FALSE, CODISTRIBUTED, CODISTRIBUTED/false.


%   Copyright 2013 The MathWorks, Inc.

    D = codistributed.pBuildFromLikeFcn(@false, varargin{:}); %#ok<DCUNK>
end
