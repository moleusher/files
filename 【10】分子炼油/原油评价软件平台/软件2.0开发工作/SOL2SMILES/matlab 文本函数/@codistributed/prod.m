function P = prod(A, varargin)
%PROD Product of elements of codistributed array
%   PROD(X)
%   PROD(X,'double')
%   PROD(X,'native')
%   PROD(X,'default')
%   PROD(X,DIM)
%   PROD(X,DIM,'double')
%   PROD(X,DIM,'native')
%   PROD(X,DIM,'default')
%   
%   The order of the products within the PROD operation is not defined, so
%   the PROD operation on a codistributed array might not return exactly the same 
%   answer as the PROD operation on the corresponding MATLAB numeric array.
%   In particular, the differences might be significant when X is a signed
%   integer type and its product is accumulated natively.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = 4 * (codistributed.colon(1, N) .^ 2);
%       D2 = D ./ (D - 1);
%       p = prod(D2);
%       norm(p-pi/2,'inf')
%   end
%   
%    p is approximately pi/2 (by the Wallis product)
%   
%   See also PROD, CODISTRIBUTED, CODISTRIBUTED/COLON, CODISTRIBUTED/ZEROS.


%   Copyright 2006-2013 The MathWorks, Inc.
    narginchk(1, 3);
    P = codistributed.pSumAndProd(@prod, A, varargin);
