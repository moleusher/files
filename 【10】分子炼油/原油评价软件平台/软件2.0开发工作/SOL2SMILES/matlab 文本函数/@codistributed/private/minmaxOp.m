function [Y, I] = minmaxOp(fcnMinMax,varargin)
%minmaxOp    template for max and min

%   Copyright 2006-2016 The MathWorks, Inc.

distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);
fcnStr = lower(func2str(fcnMinMax));

% Split off any trailing string arguments (e.g. 'omitnan')
idx = find(~cellfun(@ischar, varargin), 1, 'last');
if isempty(idx)
    % No non-char args
    trailingArgs = varargin;
    dataArgs = {};
else
    % Strip trailing args
    trailingArgs = varargin(idx+1:end);
    dataArgs = varargin(1:idx);
    % For min(x,[],'omitnan') and similar, ignore the []
    if ~isempty(trailingArgs) && numel(dataArgs)==2 && isempty(dataArgs{2})
        dataArgs(end) = [];
    end
end
numDataArgs = numel(dataArgs);
% Bind the trailing arguments into the function call
if ~isempty(trailingArgs)
    fcnMinMax = @(varargin) fcnMinMax(varargin{:}, trailingArgs{:});
end

try
    if numDataArgs == 1 || numDataArgs == 3
        % Handle fMinMax(X) and fMinMax(X, [], dim).
        X = dataArgs{1};
        if numDataArgs == 1
            dim = distributedutil.Sizes.firstNonSingletonDimension(size(X));
        else
            if ~isempty(dataArgs{2})
                % This is the same error message as with builtin min and max.
                % For example, min(3, 4, 2).
                error(message(['MATLAB:', fcnStr, ':caseNotSupported']));
            end
            dim =  distributedutil.CodistParser.gatherIfCodistributed(dataArgs{3});
            if ~isa(X, 'codistributed')
                if nargout > 1
                    [Y, I] = fcnMinMax(X, [], dim);
                else
                    Y = fcnMinMax(X, [], dim); 
                end
                return;
            end
        end
        wantI = nargout > 1;
        [Y, I] = iMinMaxAlongDim(fcnMinMax, X, dim, wantI);
    elseif numDataArgs == 2
        % Handle fMinMax(X, Y), i.e. elementwise comparison between X and Y.
        if nargout > 1
            error(message(['MATLAB:', fcnStr, ':TwoInTwoOutCaseNotSupported']));
        end
        X = dataArgs{1};
        Z = dataArgs{2};
        Y = codistributed.pElementwiseOp(fcnMinMax, X, Z); %#ok<DCUNK> private method.
    else
        error(message('MATLAB:maxrhs'));
    end
catch E
    % Error stack should only show min or max, not minmaxOp.
    throwAsCaller(E);
end

end % End of minmaxOp.

function [Y, I] = iMinMaxAlongDim(fcnMinMax, X, dim, wantI)
I = [];
if any(size(X, dim) == [0, 1])
    % min/max on a singleton dimension or an empty dimension is a no-op.
    % This is completely different from any/all/sum/prod.
    % However, we must still check that the trailing args are valid. We do
    % this by calling the function on a scalar (fcnMinMax has the trailing
    % args bound-in and this will throw if they are invalid)
    [~,~] = fcnMinMax(1, [], dim);
    % All Ok. Just copy the input.
    Y = X;
    if wantI
        I = codistributed.ones(size(X), getCodistributor(X), 'noCommunication');
    end
    return;
end
% Defer to implementation of non-trivial min-max.
codistr = getCodistributor(X);
LP = getLocalPart(X);
[LPY, LPI, codistr] = codistr.hMinMaxImpl(fcnMinMax, LP, dim, wantI);
Y = codistributed.pDoBuildFromLocalPart(LPY, codistr);  %#ok<DCUNK> private static.
if wantI
    I = codistributed.pDoBuildFromLocalPart(LPI, codistr);  %#ok<DCUNK> private static.
end

end % End of iMinMaxAlongDim.
