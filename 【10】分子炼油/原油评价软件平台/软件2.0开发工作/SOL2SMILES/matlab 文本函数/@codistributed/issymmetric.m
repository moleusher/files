function tf = issymmetric( A, skew )
%ISSYMMETRIC  Determine whether a codistributed matrix is real or complex symmetric.
%   ISSYMMETRIC(X)
%   ISSYMMETRIC(X,'skew')
%   ISSYMMETRIC(X,'nonskew')
%   
%   Example:
%   spmd
%      X = codistributed(gallery('moler',1000));
%      issymmetric(X)
%   end
%   
%   See also ISSYMMETRIC, MAGIC, CODISTRIBUTED.
%   


%   Copyright 2014-2016 The MathWorks, Inc.

% This function works for numerics, logicals and chars
if ~isfloat(A) && ~islogical(A)
    error(message('MATLAB:issymmetric:inputType'))
end

if nargin<2
    skew = false;
else
    if ~isScalarString(skew) ...
            || ~ismember(upper(skew), {'SKEW', 'NONSKEW'})
        error(message('MATLAB:issymmetric:inputFlag'));
    end
    skew = strcmpi(skew, 'SKEW');    
end

doConj = false;
tf = checkSymmetry( A, doConj, skew );

end


function tf = isScalarString(arg)
    tf = (ischar(arg) && isrow(arg)) || (isstring(arg) && isscalar(arg));
end