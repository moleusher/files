function D = infLike(varargin)
%INFLIKE Infinity codistributed array matrix
%   
%   When P is of type codistributed array:
%   D = INFLIKE(P,N) is an N-by-N codistributed matrix of INFs with
%   the same complexity and underlying class as P.
%   This is equivalent to 
%   D = INF(N,'like',P)
%   
%   D = INFLIKE(P, M,N,..., CLASSNAME) or 
%   INFLIKE(P, [M,N,...], CLASSNAME) is the M-by-N-by-...
%   codistributed matrix of INFs with underlying data of class CLASSNAME 
%   and the same complexity as P. This is equivalent to 
%   D = INF([M,N,...],CLASSNAME,'like',P)
%   
%   P must have underlying class 'single' or 'double'.
%   
%   See also INF, CODISTRIBUTED, CODISTRIBUTED/inf.


%   Copyright 2013 The MathWorks, Inc.

    D = codistributed.pBuildFromLikeFcn(@inf, varargin{:}); %#ok<DCUNK>
end
