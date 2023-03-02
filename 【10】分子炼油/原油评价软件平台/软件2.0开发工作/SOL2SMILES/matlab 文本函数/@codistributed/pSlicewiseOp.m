function out = pSlicewiseOp(fcn, varargin)
%pSlicewiseOp Perform operations on whole rows
%   D = codistributed.pSlicewiseOp(F, D1) performs the slicewise 
%   unary operation F on all rows of D1.
%   
%   D = codistributed.pSlicewiseOp(F, D1, D2, ...) performs the slicewise 
%   binary operation F on all rows of D1, D2, etc. All inputs must have
%   matching numbers of rows.
%   

%   Copyright 2016 The MathWorks, Inc.

narginchk(2, inf);
inputs = varargin;

% If no input is codistributed, call back into MATLAB. This can
% happen if a bound-in parameter was the only distributed argument.
if ~any(cellfun(@(x) isa(x, 'codistributed'), inputs))
    try
        out = fcn(inputs{:});
        return;
    catch E
        throwAsCaller(dispatchUndefinedFunctionException(E));
    end
end

distributedutil.CodistParser.verifyNonCodistributedInputs(inputs);

% Check array sizes
[ok, arraySize] = iCheckSizes(inputs);
if ~ok
    E = MException(message('MATLAB:dimagree'));
    throwAsCaller(dispatchUndefinedFunctionException(E)); % Hide the implementation stack.
end

% Make sure we are distributed by row
try
    [inputs, codistr] = iRedistributeInputs(inputs, arraySize);
catch E
    throwAsCaller(dispatchUndefinedFunctionException(E)); % Hide the implementation stack.
end

% Deconstruct into local part (or replicated)
[argLP, argCodistr] = iSplit(inputs);

if all(cellfun(@isempty, argCodistr))
    % We've ended up all replicated, we can just call the op
    try
        LP = fcn(argLP{:});
    catch E
        throwAsCaller(dispatchUndefinedFunctionException(E)); % Hide the implementation stack.
    end
    out = codistributed.pConstructFromReplicated(LP, codistr); %#ok<DCUNK>
    return;
end

% At this point we know that the local parts have whole rows. We can simply
% run the op.
LP = fcn(argLP{:});

% The op is allowed to change the size of the local parts except in
% the distribution dimension. Since all local parts should be resized
% identically we can infer the global size
gsize = size(LP);
gsize(codistr.Dimension) = sum(codistr.Partition);
outCodistr = hGetCompleteForSize(codistr, gsize);
out = codistributed.pDoBuildFromLocalPart(LP, outCodistr); %#ok<DCUNK> Calling a private static method.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ok, arraySize] = iCheckSizes(vars)
% Check that all non-scalar inputs have matching sizes, and if so return
% the expected size of the result.

% Default:
ok = true;
isScalar = cellfun(@isscalar, vars);
if all(isScalar)
    arraySize = [1, 1];
    return
end

% Filter down to the non-scalar variables.
vars = vars(~isScalar);
arraySize = size(vars{1});
otherSizesMatch = cellfun(@(x) isequal(size(x), arraySize), vars(2:end));
if ~all(otherSizesMatch)
    ok = false;
end
end % iCheckSizes


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vars, codistr] = iRedistributeInputs(vars, arraySize)
% Redistribute, scatter or gather inputs to a slice-wise function so that:
% - All scalars are gathered
% - If there is at least one array, all arrays are made
%   codistributed and use a 1D distribution scheme in the first dimension
%   (so that workers get whole slices).
%
% At least one input must be codistributed.

% Check for all scalars
isScalar = cellfun(@isscalar, vars);

% Work out which inputs are codistributed. There should be at least one.
isCodistributed = cellfun(@(x) isa(x,'codistributed'), vars);

% If any non-scalar has a 1D distribution in the first dimension, we will
% use that. Otherwise we must create a new codistributor.
firstSlicewiseCodistributor = ...
    find(cellfun(@hasSlicewiseCodistributor, vars(isCodistributed & ~isScalar)), 1, 'first');

if isempty(firstSlicewiseCodistributor)
    codistr = codistributor1d(1, codistributor1d.unsetPartition, arraySize);
else
    codistr = getCodistributor(vars{firstSlicewiseCodistributor});
end

% Now make sure all scalars are gathered and all arrays distributed the
% right way.
vars(isScalar) = distributedutil.CodistParser.gatherElements(vars(isScalar));
vars(~isScalar) = iRedistributeAll(vars(~isScalar), codistr);

end % iRedistributeInputs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = hasSlicewiseCodistributor(c)
% True if the codistributed input C has a 1D distribution in the first
% dimension.
codistr = getCodistributor(c);
tf = isa(codistr, 'codistributor1d') && (codistr.Dimension == 1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vars, codistr] = iRedistributeAll(vars, codistr)
% Redistribute all inputs using the codistributor CODISTR, if they aren't
% already.
for ii=1:numel(vars)
    if isa(vars{ii}, 'codistributed')
        if ~isequal(getCodistributor(vars{ii}), codistr)
            vars{ii} = redistribute(vars{ii}, codistr);
        end
    else
        % Input is replicated. Convert to codistributed.
        vars{ii} = codistributed.pConstructFromReplicated(vars{ii}, codistr); %#ok<DCUNK> Calling a private static method.
    end
    % codistr may have been modified
    codistr = getCodistributor(vars{ii});
end
end % iRedistributeAll

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [LP, codistr] = iSplit(D)
LP = D;
codistr = cell(size(D));

for ii=1:numel(D)
    if isa(D{ii}, 'codistributed')
        % Get codistributor and local part from codistributed array.
        LP{ii} = getLocalPart(D{ii});
        codistr{ii} = getCodistributor(D{ii});
    else
        % Leave default (LP = D, codistr = [])
    end
end
end % iSplit
