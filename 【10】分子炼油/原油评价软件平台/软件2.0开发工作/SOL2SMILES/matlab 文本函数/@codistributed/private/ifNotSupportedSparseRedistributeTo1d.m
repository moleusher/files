function [A, codistr] = ifNotSupportedSparseRedistributeTo1d(A, codistr)
% Check if codistr supports sparse, catch error and redistribute if
% necessary

%   Copyright 2016 The MathWorks, Inc.
try
    codistr.hVerifySupportsSparse();
catch
    % Create 1d codistributor with same GlobalSize as codistr and
    % redistribute data
    globalSize = codistr.Cached.GlobalSize;
    % Set distribution dimension, choose default of 2 if A is square
    [~,distDimension] = max([globalSize(1),globalSize(2)+1]);
    codistr = codistributor1d(distDimension, [], globalSize);
    A = redistribute(A, codistr);
end
end