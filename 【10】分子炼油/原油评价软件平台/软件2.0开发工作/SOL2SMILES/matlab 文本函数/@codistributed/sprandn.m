function D = sprandn(varargin)
%CODISTRIBUTED.SPRANDN Sparse normally distributed random codistributed matrix
%   
%   D = CODISTRIBUTED.SPRANDN(S) has the same sparsity structure as S, but normally
%   distributed random entries. 
%   
%   D = CODISTRIBUTED.SPRANDN(M,N,DENSITY) is a random M-by-N sparse
%   codistributed matrix with approximately DENSITY*M*N normally
%   distributed nonzero entries. 
%   
%   Optional arguments to CODISTRIBUTED.SPRANDN must be specified after the
%   size and density arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.sprandn(N, N, 0.01);
%   end
%   
%   See also SPRANDN, CODISTRIBUTED, CODISTRIBUTED.BUILD, CODISTRIBUTOR.
%   
%   


%   Copyright 2008-2015 The MathWorks, Inc.

% We currently only support:
% sprand(A)
% sprand(m, n, density [, codistr] [, 'noCommunication'])

% Must have 1 arg or 3-5 args
narginchk(1, 5);
if nargin==2
    error(message('MATLAB:sprandn:TwoInputs'))
end

try
    D = codistributed.pSprandAndSprandn(@sprandn, 'sprandn', varargin{:});
catch e
    throw(e); % Strip off stack.
end

end % End of sprandn.
