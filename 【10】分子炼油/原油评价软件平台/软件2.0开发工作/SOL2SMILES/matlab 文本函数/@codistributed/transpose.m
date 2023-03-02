function A = transpose(A)
%.' Transpose of codistributed array
%   E = D.'
%   E = TRANSPOSE(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       E = D.'
%   end
%   
%   See also TRANSPOSE, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2016 The MathWorks, Inc.

A = transposeTemplate(A, @transpose);

