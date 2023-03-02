function tf = isequalTemplate(F, varargin)
%ISEQUALTEMPLATE Template for ISEQUAL and ISEQUALWITHEQUALNANS

%   Copyright 2006-2016 The MathWorks, Inc.

    distributedutil.CodistParser.verifyNonCodistributedInputs(varargin);

    %check if all inputs have the same size
    varSizes = cellfun(@size, varargin, 'UniformOutput', false);
    isSizeCompatible = isequal(varSizes{:});

    if ~isSizeCompatible
        tf = false;
        return
    end

    % We determine the target codistributor to use for all the input cell
    % arrays.  Any replicated cell arrays will be distributed according to 
    % this target codistributor, while the codistributed arrays will be 
    % redistributed if necessary.  The local parts are returned.
    [cellLPs, targetDist] = codistributed.pRedistSameSizeToSingleDist(varargin); %#ok<DCUNK>

    tf = targetDist.hIsequalTemplateImpl(F, cellLPs);  
end
