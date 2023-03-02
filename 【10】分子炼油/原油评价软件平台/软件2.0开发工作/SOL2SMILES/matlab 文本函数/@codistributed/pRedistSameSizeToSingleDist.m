function [cellOfLPs, targetDist] = pRedistSameSizeToSingleDist(inputCells, codistConstraintFcn)
%pRedistSameSizeToSingleDist Redistribute distributed and replicated cell 
%   arrays of the same size to the same distribution scheme.  
%   
%   [cellOfLPs, targetDist] = pRedistSameSizeToSingleDist(inputCells, codistConstraintFcn) 
%   distributes all elements of inputCells according to the same 
%   codistributor, targetDist, and returns a cell array of the local 
%   parts, cellOfLPs.  At least one element of inputCells must be 
%   codistributed.  The optional constraint function determines whether the 
%   codistributor for an inputCell is suitable for the redistribution.


%   Copyright 2009-2012 The MathWorks, Inc.

    % This function assumes that all elements of inputCells have the 
    % same size.  Therefore the re-distributions should always succeed.   
        
    % Get target codistributor for several input cells.  The cells may be 
    % either distributed or replicated, and this is tracked by the variable
    % isDistributedCells.
    
    % If an optional constraint function is supplied, the target
    % codistributor will be the codistributor of the first input cell that
    % satisfies the constraint. This is tracked by firstValidCodistr
    
    % pRedistSameSizeToSingleDist must be called with exactly 1 or 2 inputs
    % If called with one input, no constraint is applied to the codistributors
    % as defined by iNoConstraint.  If called with two inputs, then we need 
    % to ensure that the second input is a function handle.

    if nargin == 1
        % No constraint function provided, so use default one
        codistConstraintFcn = @iNoConstraint;
    end
    
    % ensure that second input is a function handle
    if ~isa(codistConstraintFcn, 'function_handle')
        error(message('parallel:distributed:RedistSameSizeToSingleDistInvalidInput'));
    end
    
    isDistributedCells = cellfun(@(x) iscodistributed(x), inputCells);  
    distrCells = inputCells(isDistributedCells);
    
    if isempty(distrCells)
        error(message('parallel:distributed:RedistSameSizeToSingleDistAllReplicated'));
    end
    
    hasValidCodistr = cellfun(@(x) codistConstraintFcn(x), distrCells);
    firstValidCodistr = find(hasValidCodistr, 1);
    
    if isempty(firstValidCodistr)
        error(message('parallel:distributed:RedistSameSizeToSingleDistConstraintViolated'));
    end
    
    targetDist = getCodistributor(distrCells{firstValidCodistr});
    
    % Get the local parts of all cells. iGetLP (re)distributes if necessary 
    % so cellOfLPs are all using targetDist.
    cellOfLPs = cellfun(@(x) iGetLP(targetDist, x), inputCells, ...
                        'UniformOutput', false);
end 

%------------------------------------
function localA = iGetLP(targetDist, A)
    if iscodistributed(A)
        % redistribute to targetDist, getting localA as result
        A = redistribute(A, targetDist);
        localA = getLocalPart(A);
    else
        % build from replicated
        localA = targetDist.hBuildFromReplicatedImpl(0, A);
    end   
end 

function tf = iNoConstraint(~)
    tf = true;
end
