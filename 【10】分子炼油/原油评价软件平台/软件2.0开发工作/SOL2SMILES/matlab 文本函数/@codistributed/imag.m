function Y = imag(X)
%IMAG Complex imaginary part of codistributed array
%   Y = IMAG(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       rp = 3 * codistributed.ones(N);
%       ip = 4 * codistributed.ones(N);
%       D = complex(rp, ip);
%       E = imag(D)
%   end
%   
%   See also IMAG, CODISTRIBUTED, CODISTRIBUTED/COMPLEX, CODISTRIBUTED/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.

Y = codistributed.pElementwiseUnaryOp(@imag, X);
