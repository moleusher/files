function out = pElementwiseOp(fcn, varargin)
%pElementWiseOp Perform elementwise operations
%   D2 = codistributed.pElementWiseOp(F, D1) performs the elementwise 
%   unary operation F on all elements of D1.
%   
%   D3 = codistributed.pElementWiseOp(F, D1, D2) performs the elementwise 
%   binary operation F on all elements of D1, D2. The inputs must have matching
%   size or can be scalar.
%   
%   D4 = codistributed.pElementWiseOp(F, D1, D2, D3) performs the elementwise 
%   ternary operation F on all elements of D1, D2 and D3. The inputs must have 
%   matching size or can be scalar.
%   


%   Copyright 2014-2016 The MathWorks, Inc.

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

% If more than one input, check that they are equal size or scalar. Also
% check that the distribution schemes match.
if numel(inputs) > 1

    performImplicitExpansion = iRequireImplicitExpansion(inputs);
    
    try
        % Always perform the size checking here to get the correct error ID in the case
        % of problems.
        [ok, arraySize] = iCheckSizes(performImplicitExpansion, inputs);
        if ~ok
            error(message('MATLAB:dimagree'));
        end
        % For the case of a binary function, we now need to redirect
        % to BSXFUN to perform the dimension expansion
        if performImplicitExpansion
            out = bsxfun(fcn, inputs{:});
            return
        else
            [inputs, codistr] = iRedistributeInputs(inputs, arraySize);
        end
    catch E
        throwAsCaller(dispatchUndefinedFunctionException(E)); % Hide the implementation stack.
    end
else
    % Unary case. Just extract the codistributor.
    codistr = getCodistributor(inputs{1});
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

% Form the function arguments as [codistr, localPart] pairs
args = reshape( [argCodistr;argLP], 1, 2*numel(inputs) );

try
    [LP, codistr] = codistr.hElementwiseOpImpl(fcn, args{:});
catch E
    throwAsCaller(dispatchUndefinedFunctionException(E)); % Hide the implementation stack.
end

% Success! Build the output from the local results
out = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK> Calling a private static method.
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Returns true if the input variables *must* use implicit expansion to conform
% for the operation. This is only the case where there are exactly two variables
% whose sizes don't match the old rules (i.e. match exactly, or permit scalar
% expansion), and the variables are all numeric/logical/char.
function tf = iRequireImplicitExpansion(vars)

% If we don't have exactly 2 inputs, or if the sizes match without implicit
% expansion, then there's no need to use it.
useImplicitExpansion = false;
if numel(vars) ~= 2 || iCheckSizes(useImplicitExpansion, vars)
    tf = false;
else
    tf = all(cellfun(@(x) isnumeric(x) || islogical(x) || ischar(x), vars));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ok, arraySize] = iCheckSizes(performImplicitExpansion, vars)
% To check sizes in the automatic-expansion mode, we first discard any scalar
% inputs, and then check the non-singleton dimensions for the remaining
% inputs. The result size is the maximum size in each dimension across the
% non-scalar variables.

% Default:
ok = true;
isScalar = cellfun(@isscalar, vars);
if all(isScalar)
    arraySize = [1, 1];
    return
end

% Filter down to the non-scalar variables.
vars = vars(~isScalar);
if performImplicitExpansion
    % Get the maximum dimensionality
    numDims = max(cellfun(@ndims, vars));

    % Create a cell array where the first element contains the size of each array in
    % the first dimension etc.
    sizes = cell(1, numDims);
    [sizes{:}] = cellfun(@size, vars);
    
    % Each element of sizes should have only a single unique value after unity is
    % discarded.
    uniqueSizesExcludingUnity = cellfun(@(x) unique(x(x~=1)), sizes, ...
                                        'UniformOutput', false);
    
    % Initialize with ones - if there's no non-unity sizes in a particular
    % dimension, then this is the correct result.
    arraySize = ones(1, numel(uniqueSizesExcludingUnity));
    for idx = 1:numel(uniqueSizesExcludingUnity)
        uniqueSizesThisDim = uniqueSizesExcludingUnity{idx};
        if numel(uniqueSizesThisDim) > 1
            ok = false;
            break
        elseif numel(uniqueSizesThisDim) == 1
            arraySize(idx) = uniqueSizesThisDim;
        end
    end
else
    arraySize = size(vars{1});
    otherSizesMatch = cellfun(@(x) isequal(size(x), arraySize), vars(2:end));
    if ~all(otherSizesMatch)
        ok = false;
    end
end
end % iCheckSizes


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vars, codistr] = iRedistributeInputs(vars, arraySize)
% Redistribute, scatter or gather inputs to an elementwise function so that:
% - If all inputs are scalars, they are all gathered.
% - If there is at least one array, all arrays are made
%   codistributed and use the same distribution scheme. All
%   scalars are gathered.
%
% In particular:
% - At least one input must be codistributed.
% - At least one output will be codistributed unless all scalar.

% Check for all scalars
isScalar = cellfun(@isscalar, vars);

% Work out which inputs are codistributed. There should be at least one.
isCodistributed = cellfun(@(x) isa(x,'codistributed'), vars);
firstCodistributed = find(isCodistributed, 1, 'first');
codistr = getCodistributor(vars{firstCodistributed});

if all(isScalar)
    % All scalar. Gather them all
    vars = distributedutil.CodistParser.gatherElements(vars);
else
    % Not all scalar. Get the distribution scheme from the first
    % codistributed array. If no array is codistributed then use the
    % distribution scheme from the scalar and resize it to fit the arrays.
    firstCodistributedArray = find(isCodistributed & ~isScalar, 1, 'first');
    if isempty(firstCodistributedArray)
        % Only scalars are codistributed. Resize the codistributor to the
        % array size.
        codistr = hGetNewForSize(codistr, arraySize);
    else
        % An array is codistributed. Use its codistributor.
        codistr = getCodistributor(vars{firstCodistributedArray});
    end
    % Redistribute all arrays
    vars(~isScalar) = iRedistributeAll(vars(~isScalar), codistr);
    % Gather all scalars
    vars(isScalar) = distributedutil.CodistParser.gatherElements(vars(isScalar));
end

end % iRedistributeInputs


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
