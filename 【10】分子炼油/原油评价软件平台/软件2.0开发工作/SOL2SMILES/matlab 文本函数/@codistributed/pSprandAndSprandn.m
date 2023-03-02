function D = pSprandAndSprandn(buildFcn, fcnName, m, n, density, varargin)
%pSprandAndSprandn  A private function that implements sprand and sprandn support


% buildFcn is either @sprand or @sprandn, fcnName is the corresponding string.

%   Copyright 2009-2015 The MathWorks, Inc.

% Argument parsing.  The options are:
% buildFcn(A)
% buildFcn(m, n, density)
% buildFcn(m, n, density [, codistr] [, 'noCommunication'])
% where buildFcn is either sprand or sprandn.

% For the instance version we are replacing values in an existing array and
% can avoid a lot of the work.
if nargin==3
    A = m; % First input is an existing matrix to update, not a size.
    D = iInstanceVersion(buildFcn, A);
    return;
end

distributedutil.CodistParser.verifyNonCodistributedInputs([{m, n, density}, varargin]);

[codistr, allowCommunication] = iParseOptionalArgs(fcnName, varargin{:});
if ~allowCommunication
    distributedutil.CodistParser.verifyNotCodistWithNoComm(fcnName, ...
        {m, n, density});
end

m = distributedutil.CodistParser.gatherIfCodistributed(m);
n = distributedutil.CodistParser.gatherIfCodistributed(n);
density = distributedutil.CodistParser.gatherIfCodistributed(density);

density = iVerifyDensity(density);

% Use the error checking in CodistParser to check the input sizes.  We already
% have the sizes as m and n, so we don't need the output arguments.
allowNegativeSizes = false;
distributedutil.CodistParser.parseArraySizes({m, n}, fcnName, allowNegativeSizes);

if allowCommunication
    argsToCheck = {[m, n, density], codistr};
    distributedutil.CodistParser.verifyReplicatedInputArgs(fcnName, argsToCheck);
end

codistr.hVerifySupportsSparse();

% Map the construction of the sprand/sprandn array into the other build functions.
% Class name is empty and will therefore not be provided to the build function.
className = '';
% Function handle that can build local part.  Accepts matrix size as input.
buildFcnForLocalPart = @(sz1, sz2) buildFcn(sz1, sz2, density);
[LP, codistr] = codistr.hBuildFromFcnImpl(buildFcnForLocalPart, [m, n], className);

% We have already ascertained that we are called collectively, so no further
% error checking is needed.
D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK> private static.

end % End of spalloc.

function density = iVerifyDensity(density)

if ~isscalar(density) || ~isnumeric(density) || ~isreal(density)
    error(message('parallel:distributed:SprandInvalidDensity'))
end
% If density is outside the range, limit it
density = max(0, min(1, density));

end % End of iVerifyDensity.


function [codistr, allowCommunication] = iParseOptionalArgs(fcnName, varargin)
argList = varargin;
[argList, allowCommunication] = distributedutil.CodistParser.extractCommFlag(argList);
[argList, codistr] = distributedutil.CodistParser.extractCodistributor(argList);

% If argList is not empty at this point, the argument parsing failed.
if ~isempty(argList)
    error(message('parallel:distributed:SprandInvalidOptionalInputs', upper( fcnName )));
end

end % End of iParseOptionalArgs.

function D = iInstanceVersion(fcn, D)
% Input may be full or sparse.  Guard against ND-full input.
if ~ismatrix(D)
    msgId = sprintf('MATLAB:%s:ndInput', func2str(fcn));
    error(message(msgId));
end

if isa(D,'codistributed')
    LP = getLocalPart(D);
    codistr = getCodistributor(D);
else
    LP = D;
    codistr = codistributor(); % Default codistributor
end
clear D;

% Apply fcn to all the parts of the array, redistribute if necessary.
[LP, codistr] = codistr.hSparsifyImpl(fcn, LP);

D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
end % End of iInstanceVersion
