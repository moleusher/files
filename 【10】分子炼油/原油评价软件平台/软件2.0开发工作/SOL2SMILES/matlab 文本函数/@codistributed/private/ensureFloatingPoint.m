function A = ensureFloatingPoint(A, errorMsg, exceptedClasses )
% Helper that ensures A is a float.
% Non numerics and non logicals, as well as excepted classes defined in
% exceptedClasses, throw the error defined in errorMsg as caller.
% Non floats that do not error are converted to double.

% Copyright 2016 The MathWorks, Inc.
narginchk(2, 3);
if nargin==2
    exceptedClasses = '';
end

% Extract class of A
if iscodistributed(A)
    classA = classUnderlying(A);
else
    classA = class(A);
end

try
    % Throw for non numeric, non logical and excepted classes
    if ~(isnumeric(A) || islogical(A)) || ...
            any(strcmp(classA, exceptedClasses))
        error(message(errorMsg));
    end
    
    % Convert non floats to double
    if ~isfloat(A)
        A = double(A);
    end
    
catch ME
    throwAsCaller(ME)
end

end