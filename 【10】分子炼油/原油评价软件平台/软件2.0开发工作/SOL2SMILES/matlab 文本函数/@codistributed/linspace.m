function d = linspace(a, b, varargin)
%CODISTRIBUTED.LINSPACE Linspace codistributed array
%   CODISTRIBUTED.LINSPACE(X1, X2) generates a row vector of 100 linearly
%   equally spaced points between X1 and X2.
%   
%   CODISTRIBUTED.LINSPACE(X1, X2, N) generates N points between X1 and X2.
%   For N < 2, LINSPACE returns X2.
%    
%   X1 and X2 must be a single or double scalar. Both real and complex types are supported.
%   
%   Examples:
%   spmd
%       N  = 1000;
%       a = 0;
%       b = 10;
%       D = codistributed.linspace(a, b, N); 
%   end
%   
%   See also LINSPACE, CODISTRIBUTED, CODISTRIBUTED/LOGSPACE, CODISTRIBUTED/COLON.
%   


%   Copyright 2010-2012 The MathWorks, Inc.

narginchk(2, 5);

distributedutil.CodistParser.verifyNonCodistributedInputs([{a, b}, varargin]);

try
    [a, b, n, codistr, allowCommunication] = iParseArgs(a, b, varargin{:});
    if allowCommunication
        % Don't display CODISTRIBUTED.LINSPACE to users because they might arrive here
        % via the linspace overloads on codistributor1d and 2dbc.
        distributedutil.CodistParser.verifyReplicatedInputArgs('linspace', ...
                                                          {a, b, n, codistr});
    end
catch ME
    throw(ME);
end

[LP, codistr] = codistr.hLinspaceImpl(a, b, n);
% We have already verified that a, b, and n are called collectively, so no
% further error checking is necessary.
d = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK> private static.

end % End of codistributed.linspace.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a, b, n, codistr, allowCommunication] = iParseArgs(a, b, varargin)
% iParseArgs Input should be input arguments 3 to end of the input arguments to
% codistributed.linspace.

% First, identify all uses of 'noCommunication' and specifications of
% codistributors at the end of the argument list.
argList = varargin;
[argList, allowCommunication] = distributedutil.CodistParser.extractCommFlag(argList);
[argList, codistr] = distributedutil.CodistParser.extractCodistributor(argList);

% The only valid option is:
% {n}
switch length(argList)
    case 0 % Set n to default value
        n = 100;
    case 1 % argList must be {n}.
        n = argList{1};
    otherwise % argList{2} and up were invalid.
        error(message('parallel:distributed:LinspaceInvalidArgs'));
end
if ~allowCommunication
    distributedutil.CodistParser.verifyNotCodistWithNoComm('linspace', ...
                                                           {a, b, n});
end

a = distributedutil.CodistParser.gatherIfCodistributed(a);
b = distributedutil.CodistParser.gatherIfCodistributed(b);
n = double(distributedutil.CodistParser.gatherIfCodistributed(n));

% Verify that a, b, and n are scalars.
if ~isscalar(a) || ~isscalar(b) || ~isscalar(n)
    error(message('parallel:distributed:LinspaceNonScalarInput'));
end

if ~isfloat(a) || ~isfloat(b)  
    error(message('parallel:distributed:LinspaceOnlySupportFloat'));
end

end % End of iParseArgs.

