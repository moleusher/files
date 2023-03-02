function s = extractBetween(str,startStr,endStr,varargin)
%EXTRACTBETWEEN Create a string from part of a larger string.
%   S = EXTRACTBETWEEN(STR, START, END)
%   S = EXTRACTBETWEEN(..., 'Boundaries', B)
%   
%   See also EXTRACTBETWEEN, codistributed/STRING.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(3, 5);

% Trap bad inputs even if empty
if ~isstring(str) && ~ischar(str) && ~iscellstr(str)
    firstInput = getString(message('MATLAB:string:FirstInput'));
    error(message('MATLAB:string:MustBeCharCellArrayOrString', firstInput));
end

if isempty(str)
    s = str;
    return;
end


% Trailing arguments should always be gathered
varargin = distributedutil.CodistParser.gatherElements(varargin);

if ~iscodistributed(str)
    % Data on client. Run there.
    startStr = distributedutil.CodistParser.gatherIfCodistributed(startStr);
    endStr = distributedutil.CodistParser.gatherIfCodistributed(endStr);
    s = extractBetween(str,startStr,endStr,varargin{:});
    return;
end

% We only support 1D distributions for now
codistributed.pVerifyUsing1d('extractBetween', str); %#ok<DCUNK>
codistr = getCodistributor(str);

% Start and end must be scalar or must match the size of the first input.
% Either way, get the local data.
startStr = iCheckAndGetLocalPart(codistr, startStr);
endStr = iCheckAndGetLocalPart(codistr, endStr);

% Now work on the local part. Make sure that if any worker throws an error,
% they all do.
strLP = getLocalPart(str);
try
    outLP = extractBetween(strLP,startStr,endStr,varargin{:});
    E = [];
catch E
end
E = gcat(E);
if ~isempty(E)
    throw(E(1));
end

% Work out if a dimension was modified.
if isequal(size(strLP), size(outLP))
    % worked element-wise, so the output can just use the input
    % distribution.
    s = codistributed.pDoBuildFromLocalPart(outLP, codistr); %#ok<DCUNK>
    
else
    % Based on the global size, work out which dimension we expect to be
    % expanded/contracted, and which one actually changed.
    expectedDim = iGetExpansionDimension(codistr.Cached.GlobalSize);
    actualDim = iFindModifiedDimension(size(strLP), size(outLP));
    % If the modified dimension isn't the one we wanted, permute the local
    % part to be expanded in the expected dimension.
    if actualDim ~= expectedDim
        order = 1:max([actualDim,expectedDim,ndims(outLP)]);
        order(actualDim) = expectedDim;
        order(expectedDim) = actualDim;
        outLP = permute(outLP, order);
    end
    
    % We now need to work out the new global size. It is an error for
    % different strings to produce different numbers of results so we can
    % work out the output size based on what changed in the local part.
    outSize = codistr.Cached.GlobalSize;
    outSize(expectedDim) = size(outLP, expectedDim);
    % Take care if the dimension modified was the distribution dimension
    part = codistr.Partition;
    if expectedDim == codistr.Dimension
        if expectedDim <= length(codistr.Cached.GlobalSize)
            dimMultiplier = outSize(expectedDim) ./ codistr.Cached.GlobalSize(expectedDim);
        else
            % Input was size 1 in this dimension
            dimMultiplier = outSize(expectedDim);
        end
        part = part.*dimMultiplier;
    end
    
    % Now build the output
    outCodistr = codistributor1d(codistr.Dimension, part, outSize);
    s = codistributed.pDoBuildFromLocalPart(outLP, outCodistr); %#ok<DCUNK>
end

end

function lp = iCheckAndGetLocalPart(codistr, x)
% Make sure scalar inputs are gathered and non-scalar are distributed the
% same way as the data.

% Before checking sizes, make sure chars rows vectors are treated as scalar
x = wrapCharInput(x);

if isscalar(x)
    lp = distributedutil.CodistParser.gatherIfCodistributed(x);
    return
end

% Not scalar, so size and distribution scheme must match
if ~isequal(size(x), codistr.Cached.GlobalSize)
    error(message('MATLAB:string:InvalidPositionSize'));
end

if iscodistributed(x)
    x = redistribute(x, codistr);
else
    x = codistributed.pConstructFromReplicated(x, codistr); %#ok<DCUNK>
end
lp = getLocalPart(x);
end

function x = wrapCharInput(x)
% Helper to wrap char inputs in scalar string so that dimension expansion
% rules are honoured.
if ischar(x)
    if ~isrow(x) && ~isempty(x)
        error(message('MATLAB:string:PositionMustBeTextOrNumeric'));
    end
    x = string(x);
end
end

function dim = iGetExpansionDimension(sz)
% Find the dimension to expand/contract for the given size vector.
% This should be the first trailing unit dimension (e.g. for 1x2x3, it will
% be dimension 4; for 1x2x1 it will be dimension 3; and for 1x1 it will be
% dimension 1).
lastNonunitDim = find(sz~=1, 1, 'last');
if isempty(lastNonunitDim)
    lastNonunitDim = 0;
end
% The dimension to expand is the one after the last non-unity dimension
dim = lastNonunitDim + 1;
end

function dim = iFindModifiedDimension(szIn, szOut)
% Given input and output size vectors, find which dimension was modified.
if length(szOut) > length(szIn)
    % Expansion added a new dimension.
    dim = length(szOut);
else
    % Expansion modified an existing dimension - find it
    dim = find(szIn ~= szOut, 1, 'first');
end
end
