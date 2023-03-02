function P = cumprod(varargin)
%CUMPROD Cumulative product of elements of codistributed array
%   CUMPROD(X)
%   CUMPROD(X,DIM)
%   CUMPROD(X,DIRECTION)
%   CUMPROD(X,DIM,DIRECTION)
%   
%   The order of the products within the CUMPROD operation is not defined, so
%   the CUMPROD operation on a codistributed array might not return exactly the same 
%   answer as the CUMPROD operation on the corresponding MATLAB numeric array.
%   In particular, the differences might be significant when X is a signed
%   integer type.
%   
%   Limitations:
%   CUMPROD(___,NANFLAG) is not supported for codistributed array.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 4 * (codistributed.colon(1, N) .^ 2);
%       D2 = D ./ (D - 1);
%       c = cumprod(D2);
%       c1 = cumprod(D2,1);
%       c2 = cumprod(D2,2);
%       isequal(c1, D2) % true
%       isequal(c, c2)  % true
%       norm(c(end)-pi/2,'inf')
%   end
%   
%   c(end) is approximately pi/2 (by the Wallis product)
%   
%   See also CUMPROD, CODISTRIBUTED, CODISTRIBUTED/COLON.


%   Copyright 2006-2014 The MathWorks, Inc.

P = codistributed.pCumop(@cumprod,@times,1,varargin{:});
