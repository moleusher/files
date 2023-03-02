function A = ctranspose(A)
%' Complex conjugate transpose of codistributed array
%   E = D'
%   E = CTRANSPOSE(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = complex(codistributed.rand(N),codistributed.rand(N))
%       E = D'
%   end
%   
%   See also CTRANSPOSE, CODISTRIBUTED, CODISTRIBUTED/COMPLEX.


%   Copyright 2006-2016 The MathWorks, Inc.

A = transposeTemplate(A, @ctranspose);
    

