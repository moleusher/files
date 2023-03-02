function D = onesLike(varargin)
%ONESLIKE onesLike codistributed array 
%   
%   When P is of type codistributed array:
%   D = ONESLIKE(P,N) is an N-by-N codistributed matrix of ones with the same
%   complexity and underlying class as P. This is equivalent to 
%   D = ONES(N,'like',P)
%   
%   D = ONESLIKE(P, M,N,..., CLASSNAME) or 
%   ONESLIKE(P, [M,N,...], CLASSNAME) is the M-by-N-by-...
%   codistributed of ones of underlying class specified by CLASSNAME with 
%   the same complexity as P. This is equivalent to 
%   D = ONES([M,N,...],CLASSNAME,'like',P)
%   
%   P must be of numeric underlying class.
%   
%   See also ONES, CODISTRIBUTED, CODISTRIBUTED/ones.


%   Copyright 2013 The MathWorks, Inc.

    D = codistributed.pBuildFromLikeFcn(@ones, varargin{:}); %#ok<DCUNK>
end
