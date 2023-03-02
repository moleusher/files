function D = nanLike(varargin)
%NANLIKE Build codistributed array containing Not-a-number
%   
%   When P is of type codistributed array:
%   D = NANLIKE(P,N) is an N-by-N codistributed matrix of NANs
%   with the same complexity and underlying class as P. 
%   This is equivalent to 
%   D = NAN(N,'like',P)
%   
%   D = NANLIKE(P,M,N,..., CLASSNAME) or 
%   NANLIKE(P, [M,N,...], CLASSNAME) is an M-by-N-by-...
%   codistributed matrix of NANs of class CLASSNAME and the same complexity as 
%   P. CLASSNAME must be either 'single' or 'double'. This is equivalent to 
%   D = NAN[M,N,...],CLASSNAME,'like',P)
%   
%   P must have underlying class 'single' or 'double'.
%   
%   See also NAN, CODISTRIBUTED, CODISTRIBUTED/nan.


%   Copyright 2013 The MathWorks, Inc.

    D = codistributed.pBuildFromLikeFcn(@nan, varargin{:}); %#ok<DCUNK>
end
