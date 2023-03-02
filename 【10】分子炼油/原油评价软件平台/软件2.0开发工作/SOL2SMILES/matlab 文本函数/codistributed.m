%CODISTRIBUTED Create a CODISTRIBUTED array from replicated data
%   
%   A codistributed array is divided into segments (called local parts), each 
%   residing in the workspace of a different worker.  Because each worker has its 
%   own portion of the array to work with, you can store larger arrays and process 
%   them more quickly.  The difference between codistributed and distributed 
%   arrays is subtle and a matter of perspective.  On the client, you access the 
%   array data using distributed arrays; from one of the workers you access the 
%   data using codistributed arrays.  Therefore, a CODISTRIBUTED array created 
%   and/or manipulated within the body of an SPMD block automatically becomes a 
%   DISTRIBUTED object upon exiting the SPMD block. 
%   
%   Codistributed arrays can be constructed in a number of ways: (1) the 
%   codistributed constructor acting on a replicated array (as in the following 
%   examples), (2) using one of the static constructor methods like 
%   CODISTRIBUTED.ONES, or (3) using the CODISTRIBUTED.BUILD method to create a 
%   large codistributed array from smaller variant local parts stored on each worker.  
%   
%   Example 1:
%   spmd
%         N = 1000;
%         X = magic(N);
%         D1 = codistributed(X);
%   end
%   
%   creates a 1000-by-1000 array D1 distributed using the default distribution
%   scheme.
%   
%   Example 2:
%   spmd
%         N = 1000;
%         X = magic(N);
%         D2 = codistributed(X, codistributor('1d', 1))
%   end
%   
%   creates a 1000-by-1000 array D2 distributed by rows (over its first
%   dimension).
%   
%   Many mathematical methods are defined for codistributed arrays.  Call 
%   METHODS('CODISTRIBUTED') to see a full listing.  The following lists 
%   contain only the intrinsic methods of codistributed arrays.   
%   
%   codistributed methods:
%   codistributed/codistributed - construct from local data
%   ISCODISTRIBUTED             - return true for codistributed arrays
%   GATHER                      - retrieve data from the workers to the client
%   classUnderlying             - return the class of the elements
%   isaUnderlying               - return true if elements are of a given class
%   getCodistributor            - returns codistributor of a codistributed array
%   getLocalPart                - get local portion of a codistributed array
%   
%   codistributed static methods:
%   BUILD    - build a codistributed array from local parts
%   CELL     - build codistributed cell array
%   COLON    - build codistributed vector of form a:[d:]b
%   EYE      - build codistributed identity matrix
%   FALSE    - build codistributed array containing 'false'
%   INF      - build codistributed array containing 'Inf'
%   LINSPACE - build codistributed vector of linearly equally spaced values
%   LOGSPACE - build codistributed vector of logarithmically equally spaced values
%   NAN      - build codistributed array containing 'NaN'
%   ONES     - build codistributed array containing ones
%   RAND     - build codistributed array containing rand
%   RANDN    - build codistributed array containing randn                  
%   SPALLOC  - build empty sparse codistributed array               
%   SPEYE    - build sparse codistributed identity matrix
%   SPRAND   - build sparse codistributed array containing rand 
%   SPRANDN  - build sparse codistributed array containing randn
%   TRUE     - build codistributed array containing 'true'
%   ZEROS    - build codistributed array containing zeros
%   
%   See also CODISTRIBUTED.ONES, CODISTRIBUTED.ZEROS, CODISTRIBUTED.BUILD,
%   CODISTRIBUTED.REDISTRIBUTE, CODISTRIBUTOR, CODISTRIBUTOR1D, CODISTRIBUTOR2DBC,
%   GATHER, DISTRIBUTED.
%   


%   Copyright 2008-2016 The MathWorks, Inc.

classdef (SupportExtensionMethods = true, ...
          InferiorClasses = {?matlab.graphics.axis.Axes, ?matlab.ui.control.UIAxes, ?calendarDuration, ?categorical, ?datetime, ?duration, ?string}) ...
codistributed ...
< parallel.internal.array.NonPlottable & parallel.internal.array.HasFusedOperators

    properties(Access = private)
        Local = [];
        Codistributor = [];
        Metadata = [];
    end
    methods(Access = private, Static = true)
        function D = pConstructFromReplicated(varargin)
            D = codistributed(varargin{:});
        end
        function D = pDoBuildFromLocalPart(LP, codistr)
        % Private method to construct a codistributed array from a local part and
        % codistributor without any error checking or any deferral to the
        % codistributor.
            D = codistributed(LP, codistr, ...
                              'undocumented:ConstructFromLocalParts');
        end
        function D = pDoBuildFromReplicatedScalar(s, dim)
        % Private method to construct a codistributed scalar from replicated 
        % scalar local parts using a 1d codistributor with dimension==dim. 
        % The scalar is stored on worker 1.
            
            % Build a 1d codistributor for a scalar - distributed using dim
            codistr = codistributor1d(dim, [1, zeros(1, numlabs - 1)], ...
                [1, 1]);
            % Set local part to empty with correct size if not on worker 1
            if labindex ~= 1
                dimVec = ones(1, max(2, dim));
                dimVec(dim) = 0;
                s = zeros(dimVec, 'like', s);
            end
            % Build codistributed variable
            D = codistributed.build(s, codistr);
        end
        y = pBesselCommon(fcn, err, nu, z, scale)
        D = pBuildFromFcn(fcn, varargin)
        D = pBuildFromLikeFcn(fcn, varargin)
        varargout = pCellfunAndArrayfun(isCellfun, args);
        P = pCumop(cumFcn, adjustFcn, initVal, A, varargin);
        res = pCheckFillPattern( A, allowedPatterns );
        d = pDatetimeDurationCommon(fcn, datevecWidth, varargin);
        out = pElementwiseOp(fcn, varargin)
        varargout = pElementwiseUnaryOp(fcn, A, varargin)
        D = pElementwiseUnaryOpWithCatch(fcn, A)
        [D, isNearlySingular] = pMldivideAndMrdivide(transposeFirstMatrix, A, B)
        [sizeVec, className, codistr, allowCommunication, limits] = pParseBuildArgs(fcnName, ...
                                                          allowNegativeSizes, argList, extractCodistrFcn)
        D = pReductionOpAlongDim(fcn, A, dim)
        D = pSlicewiseOp(fcn, varargin)
        D = pSprandAndSprandn(buildFcn, fcnName, m, n, density, varargin)
        TF = pStrcmpCommon(fcn, S1, S2, varargin)
        R = pSumAndProd(fcn, A, argList)
        pVerifyUsing1d(methodName, varargin);
        [cellOfLPs, targetDist] = pRedistSameSizeToSingleDist(inputCells, codistConstraintFcn)
    end % Private static methods

    methods (Access = public, Static = true, Hidden = true)
        D = empty(varargin);
        C = hBuildFromTemplate(template, sz);
    end

    methods (Static = true)
        D = colon(a, varargin);
        D = linspace(a, b, varargin);
        D = logspace(a, b, varargin);
        D = rand(varargin);
        D = randi(varargin);
        D = randn(varargin);

        D = nan(varargin);
        function D = NaN(varargin)
            D = codistributed.pBuildFromFcn(@NaN, varargin{:}); %#ok<DCUNK>
        end
        D = zeros(varargin);
        D = ones(varargin);
        D = inf(varargin);
        function D = Inf(varargin)
            D = codistributed.pBuildFromFcn(@Inf, varargin{:}); %#ok<DCUNK>
        end
        D = true(varargin);
        D = false(varargin);

        D = cell(varargin);

        D = eye(varargin);
        D = spalloc(varargin);
        D = speye(varargin);
        D = sprand(varargin);
        D = sprandn(varargin);

        D = build(LP, codistr, noCommunication);
        D = loadobj(D);
    end % Public static methods

    methods (Access = public, Hidden = true)
        [fcnH, userData] = getRemoteFromSPMD( obj )
        D = eyeLike(varargin)
        D = falseLike(varargin)
        D = infLike(varargin)
        D = nanLike(varargin)
        D = onesLike(varargin)
        D = randLike(varargin)
        D = randiLike(varargin)
        D = randnLike(varargin)
        D = trueLike(varargin)
        D = zerosLike(varargin)
        hValidateAttributes(varargin)
        C = hTimesTranspose(A, tA, B, tB)
        C = hMldivideTranspose(A, tA, B, tB)
        sz = numArgumentsFromSubscript(t, s, context)
        
        % The following methods are overloaded only to throw a nice error, so are hidden
        varargout = sprintf(varargin);
        
        function p = properties(obj)
            % PROPERTIES Return properties of codistributed array
            %   PROPERTIES(T)
            %
            %   See also PROPERTIES, CODISTRIBUTED.
            propNames = properties(distributedutil.Allocator.extractTemplate(obj));
            
            if nargout == 0
                matlab.bigdata.internal.util.displayProperties(classUnderlying(obj), propNames);
            else
                p = reshape(propNames, [], 1);
            end
        end
    end % Public hidden methods

    methods
        function D = codistributed(varargin)
        % CODISTRIBUTED Create a codistributed array from replicated data
        % D = CODISTRIBUTED(X) distributes a replicated X using the default
        % codistributor. X must be a replicated array, namely it must have
        % the same value on all workers. SIZE(D) is the same as SIZE(X).
        %
        % D = CODISTRIBUTED(X, CODISTR) distributes a replicated X using the
        % codistributor CODISTR. X must be a replicated array, namely it must
        % have the same value on all workers. SIZE(D) is the same as SIZE(X).
        %
        % D = CODISTRIBUTED(X, SRCWORKER) and D = CODISTRIBUTED(X, SRCWORKER, CODISTR)
        % distribute a replicated array X that resides on SRCWORKER, using the
        % codistributor CODISTR. If CODISTR is omitted, the default
        % codistributor is used instead.  SIZE(D) is the same as SIZE(X). The
        % array X must be defined on all workers but only the value from SRCWORKER
        % will be used to construct D.
        %
        % D2 = CODISTRIBUTED(D1) where the input array D1 is already a
        % codistributed array, returns the array D1 unmodified.
        %
        % D2 = CODISTRIBUTED(D1, CODISTR) where the input array D1 is already a
        % codistributed array, redistributes the array D1 with codistributor
        % CODISTR.  This is the same as calling D2 = REDISTRIBUTE(D1, CODISTR).
        %
        % Example 1:
        % spmd
        %       N = 1000;
        %       X = magic(N);
        %       D1 = codistributed(X);
        % end
        %
        % creates a 1000-by-1000 array D1 distributed using the default
        % distribution scheme.
        %
        % Example 2:
        % spmd
        %       N = 1000;
        %       X = magic(N);
        %       D2 = codistributed(X, codistributor('1d', 1))
        % end
        %
        % creates a 1000-by-1000 array D2 distributed by rows (over its first
        % dimension).
        %
        % See also CODISTRIBUTED, CODISTRIBUTED.ONES, CODISTRIBUTED.ZEROS,
        % CODISTRIBUTED.BUILD, CODISTRIBUTED.REDISTRIBUTE, CODISTRIBUTOR.

            narginchk(0, 3);
            mpiInit;

            if nargin >= 1 && isa(varargin{1},'function_handle')
                error(message('parallel:distributed:NoFunctionHandle'));
            end

            % Always start with a new metadata object, even if building from an
            % existing array
            D.Metadata = distributedutil.Metadata();

            % empty constructor required by load() and save()
            if 0 == nargin
                % Return a 0-by-0 double array.
                codistr = codistributor();
                srcWorker = 0;
                X = [];
                [LP, codistr] = codistr.hBuildFromReplicatedImpl(srcWorker, X);
                D.Local = LP;
                D.Codistributor = codistr;
                return;
            end

            % An undocumented short-cut necessary for codistributed.pDoBuildFromLocalPart.
            if nargin == 3 && ischar(varargin{end}) ...
                       && strcmp(varargin{end}, 'undocumented:ConstructFromLocalParts')
                L = varargin{1};
                dist = varargin{2};
                dist.hCheckValidForLocalPart(L); % Will throw if not a valid local part
                D.Local = L;
                D.Codistributor = dist;
                return;
            end

            X = varargin{1};
            try
                if isa(X, 'codistributed')
                    D = iCodistributedFromCodistributed(X, varargin{2:end});
                else
                    [LP, dist] = iCodistributedFromReplicated(X, varargin{2:end});
                    D.Local = LP;
                    D.Codistributor = dist;
                end
            catch e
                % Strip the stack off all errors.
                throw(e);
            end
        end % constructor
    end % methods
end % classdef

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [LP, dist] = iCodistributedFromReplicated(X,varargin)
%CODISTRIBUTEDFROMREPLICATED   Distribute a replicated or variant array
%   Implements the following calls to the constructor.
%    -  X must be a replicated array for the following:
%       [LP, dist] = codistributedFromReplicated(X)
%       [LP, dist] = codistributedFromReplicated(X,DIST)
%   - X may be a variant for the following:
%       [LP, dist] = codistributedFromReplicated(X, SRCWORKER)
%       [LP, dist] = codistributedFromReplicated(X, SRCWORKER, DIST)

% The following error should never be triggered since we are in an internal
% function.
    narginchk(1, 3);

    switch(nargin)
      case 1
        srcWorker = 0;
        dist = codistributor();
      case 2
        % The second argument could be a codistributed SRCWORKER, so we need to gather it.
        gatheredArg = distributedutil.CodistParser.gatherIfCodistributed(varargin{1});
        % Disambiguate between:
        % codistributedFromReplicated(X,DIST)
        % codistributedFromReplicated(X, SRCWORKER)
        % Erroneous call
        if isa(gatheredArg, 'AbstractCodistributor')
            dist = gatheredArg;
            srcWorker = 0;
        elseif distributedutil.CodistParser.isValidLabindex(gatheredArg)
            dist = codistributor();
            srcWorker = gatheredArg;
        else
            error(message('parallel:distributed:InvalidInput'))
        end
      case 3
        % codistributedFromReplicated(X, SRCWORKER, DIST)
        srcWorker = distributedutil.CodistParser.gatherIfCodistributed(varargin{1});
        if ~distributedutil.CodistParser.isValidLabindex(srcWorker)
            error(message('parallel:distributed:IncorrectLabIndex'));
        end
        dist = varargin{2};
        if ~isa(dist, 'AbstractCodistributor')
            error(message('parallel:distributed:ReplicatedCodistributor'));
        end
    end % switch
    [LP, dist] = dist.hBuildFromReplicatedImpl(srcWorker, X);
end

function coD = iCodistributedFromCodistributed(coD, varargin)
    narginchk(1, 2);

    if nargin == 1
        return;
    end
    % 2 input arguments.  Second must be codistributor.
    codistr = varargin{1};
    if ~isa(codistr, 'AbstractCodistributor')
        error(message('parallel:distributed:ConversionCodistributor'));
    end
    coD = redistribute(coD, codistr);
end
