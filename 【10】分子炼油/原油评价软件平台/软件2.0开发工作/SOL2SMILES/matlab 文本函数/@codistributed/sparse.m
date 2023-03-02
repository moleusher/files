function A = sparse(varargin)
%SPARSE Create sparse codistributed matrix
%   S = SPARSE(F)
%   S = SPARSE(M,N)  (S is a replicated MxN sparse array with all zero entries)
%   S = SPARSE(ROWS,COLS,VALS)
%   S = SPARSE(ROWS,COLS,VALS,M,N)
%   S = SPARSE(ROWS,COLS,VALS,M,N,NZMAX)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.eye(N);
%       S = sparse(D);
%       issparse(D) % false
%       issparse(S) % true
%       isequal(S, codistributed.speye(N)) % true
%   end
%   
%   See also SPARSE, CODISTRIBUTED, CODISTRIBUTED/EYE, CODISTRIBUTED/SPEYE.


%   Copyright 2006-2016 The MathWorks, Inc.

narginchk(1, 6);
if nargin == 4
    error(message('MATLAB:minrhs'));
end

distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);

[requiredArgs, optArgs] = iIdentifyRequiredArgs(varargin);
optArgs = distributedutil.CodistParser.gatherElements(optArgs);
        
if ~any(cellfun(@(x) isa(x, 'codistributed'), requiredArgs))
% No required args are codistributed so dispatch to MATLAB 
    A = sparse(requiredArgs{:}, optArgs{:}); 
    return
end

iValidateArgs(requiredArgs, optArgs);

[LP, codistr] = iDetermineLPAndCodistr(requiredArgs);

[LP, codistr] = iCallSparseImpl(codistr, LP, optArgs);

A = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
end

function [LP, codistr] = iDetermineLPAndCodistr(args)
if numel(args) == 1
% Get local part(s) and codistributor of input:
    A = args{1};
    codistr = getCodistributor(A);
    [A, codistr] = ifNotSupportedSparseRedistributeTo1d(A, codistr);
    LP = {getLocalPart(A)};
else
    % expand scalar inputs to match non-scalars, preserving class
    numelInputs = cellfun(@numel, args, 'UniformOutput', true);
    nonscalarInputs = numelInputs(numelInputs~=1);
    if ~isempty(nonscalarInputs)
        scalarInputs = find(numelInputs == 1);
        firstNonscalarInput = find(numelInputs ~= 1, 1);
        for k = scalarInputs
            args(k) = {args{k}*ones(size(args{firstNonscalarInput}),...
                                    'like', args{k})};
        end
    end

    % make inputs the same shape if they weren't
    szArgs = cellfun(@size, args, 'UniformOutput', false);
    if ~isequal(szArgs{1}, szArgs{:})
        args = cellfun(@(x)reshape(x, szArgs{1}), args, 'UniformOutput', false);
    end
    
    % Ensure no input uses 2dbc, otherwise redistribute
    isCodistArgs = find(cellfun(@iscodistributed, args));
    for k = isCodistArgs
        codistr = getCodistributor(args{k});
        [args{k}, ~] = ifNotSupportedSparseRedistributeTo1d(args{k}, codistr);
    end

    % make inputs equally distributed and get local parts
    try
        [LP, codistr] = ...
        codistributed.pRedistSameSizeToSingleDist(args, ...
            @iIsValidCodistributor); %#ok<DCUNK>
    catch err
        if strcmp(err.identifier, ...
            'parallel:distributed:RedistSameSizeToSingleDistConstraintViolated')
            error(message('parallel:distributed:SparseInvalidCodistributor'));
        else
            rethrow(err);
        end
    end        
end

end

function [LP, codistr] = iCallSparseImpl(codistr, LP, optArgs)
if numel(LP) == 1
    try
        [LP, codistr] = codistr.hSparsifyImpl(@sparse, LP{:});
    catch e
        throwAsCaller(e); % Strip off stack.
    end
else
    % check that i and j are nonzero, positive, integer-valued
    if ~all(cellfun(@(x)(isPositiveIntegerValuedNumeric(x, false)), LP(1:2)))
        error(message('MATLAB:sparsfcn:nonIntegerIndex'));
    end  
    [globalILP, globalJLP, valsLP] = LP{:};
    requiredM = iGetMaxValue(globalILP);
    requiredN = iGetMaxValue(globalJLP);
    szCodistr = codistr.Cached.GlobalSize;
    % Get m, n, nzmax if given, otherwise use max of inputs
    switch (length(optArgs))
        case 0
            m = requiredM;
            n = requiredN;
            nzmax = szCodistr(1)*szCodistr(2);
        case 2
            m = optArgs{1};
            n = optArgs{2};
            nzmax = szCodistr(1)*szCodistr(2);
        case 3
            m = optArgs{1};
            n = optArgs{2};
            nzmax = optArgs{3};
    end
    if m < requiredM || n < requiredN
        error(message('parallel:distributed:SparseDimensionTooSmall'));
    end
    
    [LP, codistr] = codistr.hSparseImpl(globalILP, globalJLP, valsLP, m,...
        n, nzmax);
end
end

function iValidateArgs(requiredArgs, optArgs)
    try
        % error if any input is N-D
        if ~all(cellfun(@(x)(ismatrix(x)), requiredArgs))
            error(message('parallel:distributed:SparseInputsNot2d'));
        end

        % Check that required arguments are of class double or logical (g1013726).
        classes = cellfun(@distributedutil.CodistParser.class, requiredArgs,...
            'UniformOutput', false);
        if ~all(ismember(classes, {'double', 'logical'}))
            error(message('parallel:distributed:SparseInvalidDataType'));
        end

        % error if nonscalar inputs have unequal numbers of elements
        numelInputs = cellfun(@numel, requiredArgs, 'UniformOutput', true);
        nonscalarInputs = numelInputs(numelInputs>1);
        if ~isempty(nonscalarInputs) && ~all(nonscalarInputs == nonscalarInputs(1))
            error(message('parallel:distributed:SparseInconsistentInput'));
        end

        % check that optional dimensions are numeric scalars
        if ~all(cellfun(@(x)(iScalarPosIntNumeric(x)), optArgs))
            error(message('parallel:distributed:SparseNonscalarDim'));
        end
    catch E
        throwAsCaller(E); % Strip off the stack, including this function.
    end
end

function [cellOfReqArgs, cellOfOptArgs] = iIdentifyRequiredArgs(args)
    switch length(args)
        case 1
            posFirstOptArg = 2;
        case 2
            posFirstOptArg = 1;
        case {3, 5, 6}
            posFirstOptArg = 4;                        
    end
    cellOfReqArgs = args(1:posFirstOptArg-1);
    cellOfOptArgs = args(posFirstOptArg:end);
end

function tf = iIsValidCodistributor(distArray)
    tf = true;
    codistr = getCodistributor(distArray);
    if isa(codistr, 'codistributor1d') && codistr.Dimension > 2
        tf = false;
    end
end

function maxVal = iGetMaxValue(LP)
    if isempty(LP)
        maxVal = 0;
    else
        maxVal = max(LP);
    end
    maxVal = gop(@max, maxVal);
end

function tf = iScalarPosIntNumeric(arg)
    tf = isscalar(arg) && isPositiveIntegerValuedNumeric(arg, true);
end