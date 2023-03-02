function D = pBuildFromFcn(fcn, varargin)
; %#ok<NOSEM> % Undocumented
%pBuildFromFcn Hidden static method to build codistributed arrays using a 
%   build function.  All errors are thrown as caller.
%   
%   See also codistributed/ones, codistributed/zeros.


%   Copyright 2009-2013 The MathWorks, Inc.

% This error should never be triggered since this is a hidden function.
narginchk(1, Inf);

if ~isa(fcn,'function_handle')
    throwAsCaller(MException(message(...
        'parallel:distributed:CodistributedFunctionFunctionHandleInput')))
end

allowNegativeSizes = true;
try
    fcnName = func2str(fcn);
    [sizeVec, className, codistr, ~, limits] = codistributed.pParseBuildArgs( ...
        fcnName, ...
        allowNegativeSizes, ...
        varargin); %#ok<DCUNK>
catch E
    throwAsCaller(E);
end

% TODO: We should unify error checking of the sizes.  Some of the build
% functions accept sizes as a vector, some only as multiple
% arguments.
try
    if isempty(limits)
        buildFcn = fcn;
    else
        % Need to prepend limits
        buildFcn = @(varargin) fcn(limits, varargin{:});
    end
    [LP, codistr] = codistr.hBuildFromFcnImpl(buildFcn, sizeVec, className);
catch E
    throwAsCaller(E)
end
% We have already ascertained that we are called collectively, so no further
% error checking is needed.  
D = codistributed.pDoBuildFromLocalPart(LP, codistr);  %#ok<DCUNK>

end % End of pBuildFromFcn.
