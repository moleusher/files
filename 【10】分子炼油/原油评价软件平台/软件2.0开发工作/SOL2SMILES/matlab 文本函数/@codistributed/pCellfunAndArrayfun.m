function varargout = pCellfunAndArrayfun(isCellfun, argList)
%pCellfunAndArrayfun Private static method that encapsulates the commonality 
%   between cellfun and arrayfun.  All errors are thrown as caller.
%   


%   Copyright 2006-2012 The MathWorks, Inc.

try
    [fcn, arrayArgs, trailingArgs, builtinFcn] = iParseInputs(isCellfun, argList);

    % Determine which arguments are distributed.
    isDistributed = cellfun(@(x) iscodistributed(x), arrayArgs);
    
    if ~any(isDistributed)
        % None of the arguments are distributed, and all of the other arguments
        % have been gathered.  We can call the built-in function now.
        [varargout{1:nargout}] = builtinFcn(fcn, arrayArgs{:}, trailingArgs{:});
        return
    end
    
    % nargout is special, so force its evaluation in this function.
    numOutputs = nargout;
    if isCellfun
        iVerifyCellConsistency(arrayArgs);
        procFcn = @(codistr, LPs) codistr.hCellfunImpl(fcn, LPs, ...
                                                       trailingArgs, numOutputs);
    else
        iVerifyArrayConsistency(arrayArgs);
        procFcn = @(codistr, LPs) codistr.hArrayfunImpl(fcn, LPs, ...
                                                        trailingArgs, numOutputs);
    end
    [cellOfLPs, targetDist] = codistributed.pRedistSameSizeToSingleDist(arrayArgs); %#ok<DCUNK>
    cellOfLPs = procFcn(targetDist, cellOfLPs);

    varargout = cell(1, nargout);
    for i = 1:nargout
       varargout{i} = codistributed.pDoBuildFromLocalPart(cellOfLPs{i}, targetDist); %#ok<DCUNK>
    end 
catch E
    throwAsCaller(E); % Strip ourselves from the stack.
end
end % End of pCellfunAndArrayfun.


function [fcn, arrayArgs, trailingArgs, builtinFcn] = iParseInputs(isCellfun, argList)
% Separate input arguments into its component types.  In the calls
% cellfun(FUN, A, B, ..., 'Param1', val1, ...)
% arrayfun(FUN, A, B, ..., 'Param1', val1, ...)
% fcn stores FUN
% arrayArgs stores {A, B, ...}, trailingArgs stores {'Param1', val1, ...}.
% builtinFcn stores either @arrayfun or @cellfun.

distributedutil.CodistParser.verifyNonCodistributedInputs(argList);
fcn = distributedutil.CodistParser.gatherIfCodistributed(argList{1});
argList = argList(2:end);
if isCellfun
    iVerifyCellfcn(fcn);
    [isOldSyntax, arrayArgs, trailingArgs] = iParseOldCellSyntax(fcn, argList);
    if ~isOldSyntax
        [arrayArgs, trailingArgs] = iSeparatePVPairs(argList);
    end
    builtinFcn = @cellfun;
else
    iVerifyArrayfcn(fcn);
    [arrayArgs, trailingArgs] = iSeparatePVPairs(argList);
    builtinFcn = @arrayfun;
end

end % End of iParseInputs.

function iVerifyCellfcn(fcn)
% Error check the function handle argument to cellfun.
% For backwards compatibility, cellfun accepts a string as well as 
% a function handle.
isValid = any(strcmp(distributedutil.CodistParser.class(fcn), ...
                     {'function_handle', 'char'}));
if ~isValid
    % Just like in base MATLAB, error message doesn't mention possibility 
    % of char.
    error(message('parallel:distributed:CellfunFunctionHandleRequired'));
end
end % End of iVerifyCellfcn.

function iVerifyArrayfcn(fcn)
% Error check the function handle argument to arrayfun.
% arrayfun only accepts a function handle.
isValidFcn = strcmp(distributedutil.CodistParser.class(fcn), ...
                    {'function_handle'});
if ~isValidFcn
    error(message('parallel:distributed:ArrayfunFunctionHandleRequired'));
end
end % End of iVerifyArrayfcn.

function [isOldSyntax, arrayArgs, trailingArgs] = iParseOldCellSyntax(fcn, argList)
% Handle backwards compatibility support for cellfun.  
% That is: cellfun('size', A, k) and cellfun('isclass', C, classname).  
% We let trailingArgs contain {k} and {classname}, respectively.
isOldSyntax = false;
arrayArgs = {};
trailingArgs = {};
if ischar(fcn) && any(strcmp(fcn, {'size', 'isclass'}))
    isOldSyntax = true;
    arrayArgs = argList(1:end - 1);
    trailingArgs = argList(end); % The only non-cell array input.
    trailingArgs = distributedutil.CodistParser.gatherElements(trailingArgs);
end 
end % End of iParseOldCellSyntax.

function [arrayArgs, pvPairs] = iSeparatePVPairs(argList)
% Separate the input arguments to cellfun/arrayfun into the array arguments and
% the PV-pairs.

% We search through backwards through the argList array to find where the
% trailing arguments to cellfun/arrayfun (if any) begin.  There must be 
% at least 1 array input, then possibly a P and a V.
numRequiredInputs = 1;
% Calculate the possible positions of the properties.  We search 
% backwards starting at the second to last element in argList.
lastPossiblePos = length(argList) - 1;
possiblePropPos = lastPossiblePos:-2:numRequiredInputs+1;
% Initialize the position of the first property so that
% argList(firstPropPos:end) is empty.
firstPropPos = length(argList) + 1;
% Search backwards, and stop when we find something other than a PV-pair.
for pos = possiblePropPos
    if iIsValidPVPair(argList{pos}, argList{pos+1})
        firstPropPos = pos;
    else
        break;
    end
end

% Split the argList into arrayArgs and pvPairs.
arrayArgs = argList(1:firstPropPos-1);
pvPairs = argList(firstPropPos:end);
pvPairs = distributedutil.CodistParser.gatherElements(pvPairs);    

end % End of iSeparatePVPairs.

function isValid = iIsValidPVPair(prop, value)
% Return true if and only if prop is a valid property to pass to
% arrayfun/cellfun and value is a valid value for that property.  Perform
% minimal communication while doing the checks.

% Set up the list of valid property names and a corresponding cell array of
% validation functions.
allProperties = {'UniformOutput', 'ErrorHandler'};
isLogicalValue = @(x) (islogical(x) || isequal(x, 0) || isequal(x, 1));
isUniformOutputValue = @(x) isscalar(x) && isLogicalValue(gather(x));
isErrorHandlerValue = @(x) isa(x, 'function_handle');
validatorFcn = {isUniformOutputValue, isErrorHandlerValue};

maxPropLength = max(cellfun(@length, allProperties));
isValid = false;
if strcmp(distributedutil.CodistParser.class(prop), 'char') && ...
        length(prop) <= maxPropLength
    % We may have a valid property.  Now do the more expensive checks, such as
    % gathering the property names and their values.
    % cellfun and arrayfun only require 2 characters to be present from the
    % property name.
    numCharsRequired = 2;
    ind = strncmpi(gather(prop), allProperties, ...
                  max([numCharsRequired, length(prop)]));
    if any(ind)
        validate = validatorFcn{ind};
        isValid = validate(value);
    end
end
end % End of iIsValidPVPair.

function iVerifyArrayConsistency(inputArrays)
% Perform error checking for arrayfun: inputArrays must all be arrays of the
% same size.
    
szCells = cellfun(@size, inputArrays, 'UniformOutput', false);
if ~isequal(szCells{1}, szCells{:})
    error(message('parallel:distributed:ArrayfunInputsMustBeSameSize')); 
end
end % End of iVerifyArrayConsistency.


function iVerifyCellConsistency(inputCells)
% Perform error checking for cellfun: inputCells must all be cell arrays of the
% same size.
    
isInputCellArray = cellfun(@(x) strcmp(distributedutil.CodistParser.class(x), ...
                                       'cell'), inputCells);
if ~all(isInputCellArray)
    firstNonCell = find(~isInputCellArray, 1); 
    error(message('parallel:distributed:CellfunNotACell', distributedutil.CodistParser.class( inputCells{ firstNonCell } )));
end

szCells = cellfun(@size, inputCells, 'UniformOutput', false);
if ~isequal(szCells{1}, szCells{:})
    error(message('parallel:distributed:CellfunInputsMustBeSameSize')); 
end
end % End of iVerifyCellConsistency.
