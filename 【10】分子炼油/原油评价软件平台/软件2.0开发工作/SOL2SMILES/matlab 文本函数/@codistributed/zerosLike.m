function D = zerosLike(varargin)
%ZEROSLIKE zerosLike codistributed array
%   
%   When P is of type codistributed array:
%   D = ZEROSLIKE(P,N) is an N-by-N codistributed matrix of zeros with the same 
%   complexity and underlying class as P. This is equivalent to 
%   D = ZEROS(N,'like',P)
%   
%   D = ZEROSLIKE(P, M,N,..., CLASSNAME) or 
%   ZEROSLIKE(P, [M,N,...], CLASSNAME) is an M-by-N-by-... 
%   codistributed array of zeros of underlying class specified by CLASSNAME with 
%   the same complexity as P. This is equivalent to 
%   D = ZEROS([M,N,...],CLASSNAME,'like',P)
%   
%   P must be of numeric underlying class.
%   
%   See also ZEROS, CODISTRIBUTED, CODISTRIBUTED/zeros.


%   Copyright 2013 The MathWorks, Inc.

    D = codistributed.pBuildFromLikeFcn(@zeros, varargin{:}); %#ok<DCUNK>
end
