function D = spalloc(m, n, nzmx, varargin)
%CODISTRIBUTED.SPALLOC Allocate space for sparse codistributed matrix
%   SD = CODISTRIBUTED.SPALLOC(M,N,NZMAX) creates an M-by-N all-zero sparse 
%   codistributed matrix with room to eventually hold NZMAX nonzeros.
%   
%   Optional arguments to CODISTRIBUTED.SPALLOC must be specified after the
%   required arguments, and in the following order:
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
%       SD = codistributed.spalloc(N, N, 2*N);
%       for ii=1:N-1
%         SD(ii,ii:ii+1) = [ii ii];
%       end
%   end
%   
%   See also SPALLOC, CODISTRIBUTED, CODISTRIBUTED.BUILD, CODISTRIBUTOR.
%   


%   Copyright 2008-2012 The MathWorks, Inc.

narginchk(3, 5);

distributedutil.CodistParser.verifyNonCodistributedInputs([{m, n, nzmx}, varargin]);

% Argument parsing.  The options are:
% spalloc(m, n, nzmx)
% spalloc(m, n, nzmx, codistr)
% spalloc(m, n, nzmx, 'noCommunication')
% spalloc(m, n, nzmx, codistr, 'noCommunication')

try
    [codistr, allowCommunication] = iParseOptionalArgs(varargin{:});
    [m, n, nzmx] = iParseRequiredArgs(m, n, nzmx, allowCommunication);
    if allowCommunication
        distributedutil.CodistParser.verifyReplicatedInputArgs('spalloc', ...
                                                          {m, n, nzmx, codistr});
    end
catch e
    throw(e); % Strip off stack.
end

try
    codistr.hVerifySupportsSparse();
    [LP, codistr] = codistr.hSpallocImpl(m, n, nzmx);
catch e
    throw(e); % Strip off stack.
end

% We have already ascertained that we are called collectively, so no further
% error checking is needed.  
D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK> private static.
    
end % End of spalloc.

function [m, n, nzmx] = iParseRequiredArgs(m, n, nzmx, allowCommunication)

if ~allowCommunication 
    distributedutil.CodistParser.verifyNotCodistWithNoComm('spalloc', ...
                                                      {m, n, nzmx});
end
allowNegativeSizes = false;
sizeVec = distributedutil.CodistParser.parseArraySizes({m, n}, 'spalloc', allowNegativeSizes);
m = sizeVec(1);
n = sizeVec(2);
nzmx = distributedutil.CodistParser.gatherIfCodistributed(nzmx);

% Validate m, n and nzmx:
allowZeros = true;
if ~isscalar(nzmx) || ...
        ~isPositiveIntegerValuedNumeric(nzmx, allowZeros)
    error(message('parallel:distributed:SpallocInvalidNzmx'))
end

end % End of iVerifyRequiredArgs.

function [codistr, allowCommunication] = iParseOptionalArgs(varargin)
argList = varargin;
numOptArgs = length(argList);
[argList, allowCommunication] = distributedutil.CodistParser.extractCommFlag(argList);
[argList, codistr] = distributedutil.CodistParser.extractCodistributor(argList);

% If argList is not empty at this point, the argument parsing failed.
if ~isempty(argList)
    if numOptArgs == 1
        error(message('parallel:distributed:SpallocInvalidOneOptionalInput'));
    else
        error(message('parallel:distributed:SpallocInvalidTwoOptionalInputs'));
    end
end

end % End of iParseOptionalArgs.
