function d = pDatetimeDurationCommon(fcn, datevecWidth, varargin)
%pDatetimeDurationCommon Common logic for constructing datetimes and durations
%   D = codistributed.pDatetimeDurationCommon(FCN, DATEVECWIDTH, ...) performs
%   input checking, redistribution as required and calls FCN with the relevant 
%   arguments.


%   Copyright 2016 The MathWorks, Inc.

distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);

[dataArgs, trailingArgs] = iFindDataArgs(varargin{:});

% Gather all trailing args and see if we are still distributed
trailingArgs = distributedutil.CodistParser.gatherElements(trailingArgs);
if ~any(cellfun(@iscodistributed, dataArgs))
    % Only the trailing arguments were codistributed. Redirect to client
    % function.
    d = fcn(dataArgs{:}, trailingArgs{:});
    return;
end

% Scan trailing args to see if we must treat the input as a datenum
convertEachValue = iParseTrailingArgs(trailingArgs);

% If we have one input and it is a numeric matrix with the right number of
% columns, treat it as a datevec unless told not to.
if ~convertEachValue ...
        && numel(dataArgs)==1 && isnumeric(dataArgs{1}) ...
        && ismatrix(dataArgs{1}) ...
        && ismember(size(dataArgs{1},2), datevecWidth)
    d = iConstructFromDatevec(fcn, dataArgs{1}, trailingArgs);
    return
end

% All other cases can be treated element-wise on the data inputs with the
% trailing inputs (which are now gathered) bound-in.
fcn = @(varargin) fcn(varargin{:}, trailingArgs{:});
% Make sure that if any worker throws, they all do
d = distributedutil.syncOnError(@codistributed.pElementwiseOp, fcn, dataArgs{:});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dataArgs, trailingArgs] = iFindDataArgs(varargin)
% Determine which arguments are data and which are trailing options. We do
% not accept char vectors as data, so the first char vector indicates the
% start of trailing options.
trailingIdx = find(cellfun(@ischar, varargin), 1, 'first');
if isempty(trailingIdx)
    % No trailing args
    dataArgs = varargin;
    trailingArgs = {};
elseif trailingIdx==1
    % No data args?
    dataArgs = {};
    trailingArgs = varargin;
else
    dataArgs = varargin(1:trailingIdx-1);
    trailingArgs = varargin(trailingIdx:end);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function convertEachValue = iParseTrailingArgs(args)
% parse the trailing arguments to see if we should treat the input as a
% datenum.
convertEachValue = false;
if isempty(args)
    return;
end
params = args(1:2:end);

% Look for a partial case-insensitive match for ConvertFrom
match = cellfun( @(x) (ischar(x) && ~isempty(x) && strncmpi(x, 'ConvertFrom', numel(x))), params );
convertEachValue = any(match);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = iConstructFromDatevec(fcn, dv, trailingArgs)
dvDist = getCodistributor(dv);

% Make sure workers have whole rows
if ~isa(dvDist, 'codistributor1d') || (dvDist.Dimension == 2)
    dv = redistribute(dv, codistributor('1d',1));
    dvDist = getCodistributor(dv);
end
% Make sure that if any worker throws, they all do
outLP = distributedutil.syncOnError(fcn, getLocalPart(dv), trailingArgs{:});

% Output has same number of (global and local) rows as input, but only one
% column.
numRows = size(dv,1);
outDist = codistributor1d(1, dvDist.Partition, [numRows, 1]);

t = codistributed.pDoBuildFromLocalPart(outLP, outDist);

end

