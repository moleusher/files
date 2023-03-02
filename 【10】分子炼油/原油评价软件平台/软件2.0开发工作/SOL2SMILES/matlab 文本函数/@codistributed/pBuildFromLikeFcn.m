function D = pBuildFromLikeFcn(fcn, varargin)
    ; %#ok<NOSEM> % Undocumented
%pBuildFromLikeFcn Hidden static method to build codistributed arrays using a 
%   'like' build function.  All errors are thrown as caller.
%   
%   See also codistributed/onesLike, codistributed/zerosLike.


%   Copyright 2013-2016 The MathWorks, Inc.

    % This error should never be triggered since this is a hidden function.
    narginchk(1, Inf);

    if ~isa(fcn,'function_handle')
        throwAsCaller(MException(message(...
            'parallel:distributed:CodistributedFunctionFunctionHandleInput')))
    end
    y = varargin{1};
    extractCodistrFcn = @distributedutil.CodistParser.extractCodistributorNoDefault;
    buildFcnName = func2str(fcn);
    allowNegativeSizes = true;

    try
        [sizeVec, className, codistr, ~, limits] = codistributed.pParseBuildArgs( ...
            buildFcnName, ...
            allowNegativeSizes, ...
            varargin(2:end), ... % Ignore prototype (1st arg)
            extractCodistrFcn); %#ok<DCUNK>

        % if output is to be codistributed, make sure we have a codistributor
        if isempty(codistr)
            codistr = getCodistributor(y);
        end
        % Get size of codistributor right
        codistr = codistr.hGetNewForSize(sizeVec);

        % Determine class of output
        if isempty(className)
            className = distributedutil.CodistParser.class(y);
        end

        % Construct prototype
        % This call doesn't make sense if the prototype is invalid
        % for the type of data we are trying to construct.
        iCheckClassName(buildFcnName, className);
        proto = cast(1, className); % Prototype has non-zero value to prevent imag part being lost

        % It only makes sense to "complexify" a numeric, real array.
        if ~isreal(y) && isnumeric(proto)
            proto = complex(proto, proto);
        end

        % Sparsity only makes sense for numeric arrays.
        if issparse(y)
            try
                proto = sparse(proto);
            catch ME
                if strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
                    ME = MException(message('MATLAB:unimplementedSparseType'));
                end
                throw(ME);
            end
            doUseSizeAsVector = false;
            if numel(sizeVec) > 2
                % No support for N-D sparse arrays
                error(message('parallel:array:UnsupportedNdSparse'));
            end
            if isempty(limits)
                buildFcn = @(sz1,sz2)fcn(sz1, sz2, 'like', proto);
            else
                buildFcn = @(sz1,sz2)fcn(limits, sz1, sz2, 'like', proto);
            end
        else
            doUseSizeAsVector = true;
            if isempty(limits)
                buildFcn = @(szVector)fcn(szVector, 'like', proto);
            else
                buildFcn = @(szVector)fcn(limits, szVector, 'like', proto);
            end
        end
        [LP, codistr] = codistr.hBuildFromFcnImpl(buildFcn, sizeVec, [], ...
                                                  doUseSizeAsVector);
    catch E
        throwAsCaller(E);
    end
    D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
end

function iCheckClassName(buildFcnName, className)
% Check that build function and 'like' class are consistent
    switch buildFcnName
        case {'inf', 'nan', 'rand', 'randn'}
            if ~strcmpi(className, {'single', 'double'})
                error(iGetTypeError(buildFcnName));
            end
        case {'true', 'false'}
            if ~strcmpi(className, 'logical')
                error(iGetTypeError(buildFcnName));
            end
        case {'ones', 'zeros', 'eye'}
            if ~distributedutil.CodistParser.isValidNumericOrLogicalType(className)
                error(iGetTypeError(buildFcnName));
            end
        case {'randi'}
            if ~distributedutil.CodistParser.isValidTypecastDataType(className)
                error(iGetTypeError(buildFcnName));
            end
        otherwise
            assert(false, 'Unsupported build function encountered.')
    end

end

function msg = iGetTypeError(buildFcnName)
% Get the right message ID to use for an incorrect 'like' type.
% Unfortunately this depends in the function name in a non-trivial way.
    switch buildFcnName
        case {'inf', 'true', 'false'}
            % These ones capitalize just the first letter
            errId = [upper(buildFcnName(1)), buildFcnName(2:end)];
        case 'nan'
            % nan is special
            errId = 'NaN';
        otherwise
            % For everything else, assume the ID is the name
            errId = buildFcnName;
    end
    msg = message(['MATLAB:',errId,':invalidInputClass']);
end
