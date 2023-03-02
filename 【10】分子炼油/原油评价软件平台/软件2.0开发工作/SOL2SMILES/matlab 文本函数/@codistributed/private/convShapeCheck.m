function [isSame,isValid] = convShapeCheck(errID, shape)
% Helper to check the shape input

% Copyright 2015 The MathWorks, Inc.

if nargin < 2
    shape = 'full';
else
    % Check not empty
    if ~ischar(shape) || isempty(shape)
        error(message(errID));
    end
end
isFull = strncmpi(shape,'full',length(shape));
isValid = strncmpi(shape,'valid',length(shape));
isSame = strncmpi(shape,'same',length(shape));

if ~isFull && ~isSame  && ~isValid
    error(message(errID));
end
end