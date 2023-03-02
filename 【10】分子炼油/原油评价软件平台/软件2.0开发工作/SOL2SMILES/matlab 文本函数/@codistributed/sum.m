function S = sum(A, varargin)
%SUM Sum of elements of codistributed array
%   SUM(X)
%   SUM(X,'double')
%   SUM(X,'native')
%   SUM(X,'default')
%   SUM(X,DIM)
%   SUM(X,DIM,'double')
%   SUM(X,DIM,'native')
%   SUM(X,DIM,'default')
%   SUM(...,'omitnan')
%   SUM(...,'includenan')
%   
%   The order of the additions within the SUM operation is not defined, so
%   the SUM operation on a codistributed array might not return exactly the same 
%   answer as the SUM operation on the corresponding MATLAB numeric array.
%   In particular, the differences might be significant when X is a signed
%   integer type and its sum is accumulated natively.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.colon(1,N);
%       s = sum(D);
%       isequal(s, (1+N)*N/2) % true
%   end
%   
%   See also SUM, CODISTRIBUTED, CODISTRIBUTED/ZEROS.
%   
%   


%   Copyright 2006-2014 The MathWorks, Inc.
    narginchk(1, 4);
    S = codistributed.pSumAndProd(@sum, A, varargin);

