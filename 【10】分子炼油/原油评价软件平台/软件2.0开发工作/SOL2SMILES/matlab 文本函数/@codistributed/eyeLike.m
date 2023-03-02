function D = eyeLike(varargin)
%EYELIKE Identity codistributed array matrix
%   
%   When P is of type codistributed array:
%   D = EYELIKE(P,N) is an N-by-N codistributed matrix with ones on
%   the diagonal and zeros elsewhere, and the same complexity and
%   underlying class as P. This is equivalent to 
%   D = EYE(N,'like',P)
%   
%   D = EYELIKE(P,M,N, CLASSNAME) or 
%   EYELIKE(P, [M,N], CLASSNAME) is the M-by-N 
%   codistributed identity matrix with underlying data of class CLASSNAME 
%   and the same complexity as P. This is equivalent to 
%   D = EYE([M,N],CLASSNAME,'like',P)
%   
%   P must be of numeric underlying class.
%   
%   See also EYE, CODISTRIBUTED, CODISTRIBUTED/eye.


%   Copyright 2013-2015 The MathWorks, Inc.

% Longest possible call sequence is:
% eyeLike(prototype, m, n, 'single', codistributor1d(), 'noCommunication')
% Also, we can only get here by being passed a prototype.
narginchk(1, 6);

extractCodistrFcn = @distributedutil.CodistParser.extractCodistributorNoDefault; 
prototype = varargin{1};
allowNegativeSizes = true;

try
    [sizeVec, className, codistr] = codistributed.pParseBuildArgs('eye', ...
                                                      allowNegativeSizes, ...
                                                      varargin(2:end), ... %Ignore prototype (1st arg)
                                                      extractCodistrFcn); %#ok<DCUNK>

    % if output is to be codistributed, make sure we have a codistributor
    if isempty(codistr)
        codistr = getCodistributor(prototype);
    end
    
    % Get size of codistributor right
    codistr = codistr.hGetNewForSize(sizeVec);
     
    % Determine class of output
    if isempty(className)
        className = distributedutil.CodistParser.class(prototype);
    end 
    
    if ~distributedutil.CodistParser.isValidNumericOrLogicalType(className)
        error(message('parallel:array:TrailingInputMustBeNumeric'));
    end
     
    if length(sizeVec) > 2
        error(message('parallel:distributed:EyeTooHighDim', length(sizeVec)));
    end
    
    [LP, codistr] = hEyeImpl(codistr, sizeVec(1), sizeVec(2), className);  
    
    if ~isreal(prototype)
        LP = complex(LP);
    end
    
    if issparse(prototype)
        LP = sparse(LP);
    end
catch E
    throw(E);
end

% The argument parsing already ascertained that we are called collectively, so
% no further error checking is needed.
D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
end 
