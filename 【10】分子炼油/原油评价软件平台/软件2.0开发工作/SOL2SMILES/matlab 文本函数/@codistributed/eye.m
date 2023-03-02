function D = eye(varargin)
%CODISTRIBUTED.EYE Identity codistributed matrix
%   D = CODISTRIBUTED.EYE(N) is the N-by-N codistributed matrix with ones on
%   the diagonal and zeros elsewhere.
%   
%   D = CODISTRIBUTED.EYE(M,N) or CODISTRIBUTED.EYE([M,N]) is the M-by-N 
%   codistributed matrix with ones on the diagonal and zeros elsewhere.
%   
%   D = CODISTRIBUTED.EYE() is the codistributed scalar 1.
%   
%   D = CODISTRIBUTED.EYE(M,N,CLASSNAME) or CODISTRIBUTED.EYE([M,N],CLASSNAME)
%   is the M-by-N codistributed identity matrix with underlying data of 
%   class CLASSNAME.
%   
%   Other optional arguments to CODISTRIBUTED.EYE must be specified after the
%   size and class arguments, and in the following order:
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   D = EYE(...,'like',P) for a CODISTRIBUTED argument P returns a CODISTRIBUTED identity matrix of the 
%   same complexity as P and the requested size. If CLASSNAME is not specified then D has the
%   same underlying class as P. P must be of numeric or logical underlying class.
%   If CODISTR is not supplied as an optional argument, D will have the same
%   codistributor as P.
%   
%   Example:
%   spmd
%       N = 1000;
%       % Create a 1000-by-1000 codistributed array with underlying class 'int32'.
%       D1 = codistributed.eye(N,'int32');
%       % D2 is a 2000-by-2000 codistributed array with the same underlying class
%       D2 = eye(2000,'like',D1); 
%       % N-by-N codistributed array, distributed by the first 
%       % dimension (rows):
%       D3 = codistributed.eye(N, codistributor('1d', 1));
%       % Underlying class 'single, using 2D block-cyclic codistributor:
%       D4 = eye(N, 'single', codistributor2dbc(), 'noCommunication', 'like', D3);
%   end
%   
%   See also EYE, CODISTRIBUTED, CODISTRIBUTED.BUILD, CODISTRIBUTOR.
%   


%   Copyright 2008-2015 The MathWorks, Inc.

% Longest possible call sequence is:
% codistributed.eye(m, n, 'single', codistr, 'noCommunication').
narginchk(0, 5);

try
    allowNegativeSizes = true;
    [sizeVec, className, codistr] = codistributed.pParseBuildArgs('eye', allowNegativeSizes, varargin); %#ok<DCUNK>
catch E
    throw(E);
end

if length(sizeVec) > 2
    error(message('parallel:distributed:EyeTooHighDim', length( sizeVec )));
end

try
    [LP, codistr] = codistr.hEyeImpl(sizeVec(1), sizeVec(2), className);
catch E
    throw(E);
end

% The argument parsing already ascertained that we are called collectively, so
% no further error checking is needed.
D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>

end % End of eye.
