function [A, origDistA, isRedistributed] = redistributeIfNeeded(A, newDistA)
% REDISTRIBUTEIFNEEDED
% Function that checks if A is distributed using newDistA.
% Otherwise, A is redistributed and the original distribution scheme,
% as well as a flag that indicates the redistribution, is returned.

%   Copyright 2016 The MathWorks, Inc.

isRedistributed = false;

% Check if A is distributed
if ~isa(A, 'codistributed')
    A = codistributed.pConstructFromReplicated(A, newDistA); %#ok<DCUNK>
    % Use the same distribution scheme for solution.
    origDistA = newDistA;
else
    % Save original distribution scheme for later use
    origDistA = getCodistributor(A);
    
    % Redistribute if distribution scheme is not the needed one
    if ~strcmp(class(origDistA), class(newDistA)) || (...
            isa(origDistA,'codistributor1d') && ...
            ~(origDistA.Dimension==newDistA.Dimension && ...
            min(origDistA.Partition==newDistA.Partition)))
    
            A = redistribute(A, newDistA);
            isRedistributed = true;
    end
end
end