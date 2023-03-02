function D = speye(varargin)
%CODISTRIBUTED.SPEYE Sparse identity codistributed matrix
%   D = CODISTRIBUTED.SPEYE(N) is the N-by-N codistributed matrix with ones on 
%   the  diagonal and zeros elsewhere.
%   
%   D = CODISTRIBUTED.SPEYE(M,N) or CODISTRIBUTED.SPEYE([M,N]) is the M-by-N 
%   codistributed matrix with ones on the diagonal and zeros elsewhere.
%   
%   Optional arguments to CODISTRIBUTED.SPEYE must be specified after the 
%   size arguments, and in the following order:
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
%       D = codistributed.speye(N);
%   end
%   
%   See also SPEYE, CODISTRIBUTED, CODISTRIBUTED.BUILD, CODISTRIBUTOR.
%   


%   Copyright 2008-2014 The MathWorks, Inc.

% Longest possible call sequence is:
% codistributed.speye(m, n, codistr, 'noCommunication').
narginchk(0, 4);

try
    allowNegativeSizes = false;
    [sizeVec, className, codistr] = codistributed.pParseBuildArgs('speye', allowNegativeSizes, varargin); %#ok<DCUNK>
catch E
    throwAsCaller(E);
end

if length(sizeVec) > 2
    error(message('parallel:distributed:SpeyeTooHighDim', length( sizeVec )));
end

if ~isempty(className)
    error(message('parallel:distributed:SpeyeInvalidArgument', className));
end

try
    codistr.hVerifySupportsSparse();
    [LP, codistr] = codistr.hSpeyeImpl(sizeVec(1), sizeVec(2));
catch E
    throwAsCaller(E);
end

% The argument parsing already ascertained that we are called collectively, so
% no further error checking is needed.
D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>

end % End of speye.
