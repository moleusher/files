function P = cumsum(varargin)
%CUMSUM Cumulative sum of elements of codistributed array
%   CUMSUM(X)
%   CUMSUM(X,DIM)
%   CUMSUM(X,DIRECTION)
%   CUMSUM(X,DIM,DIRECTION)
%   
%   The order of the additions within the CUMSUM operation is not defined, so
%   the CUMSUM operation on a codistributed array might not return exactly the same 
%   answer as the CUMSUM operation on the corresponding MATLAB numeric array.
%   In particular, the differences might be significant when X is a signed
%   integer type.
%   
%   Limitations:
%   CUMSUM(___,NANFLAG) is not supported for codistributed array.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1, N);
%       c = cumsum(D);
%       c1 = cumsum(D,1);
%       c2 = cumsum(D,2);
%       isequal(c1, D)             % true
%       isequal(c, c2)             % true
%       isequal(c(end), (1+N)*N/2) % true 
%   end
%   
%   See also CUMSUM, CODISTRIBUTED, CODISTRIBUTED/COLON.


%   Copyright 2006-2014 The MathWorks, Inc.

P = codistributed.pCumop(@cumsum,@plus,0,varargin{:});
