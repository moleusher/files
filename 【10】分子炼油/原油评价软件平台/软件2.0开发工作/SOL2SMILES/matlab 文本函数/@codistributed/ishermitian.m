function tf = ishermitian( A, skew )
%ISHERMITIAN  Determine whether a codistributed matrix is real symmetric or complex Hermitian.
%   ISHERMITIAN(X)
%   ISHERMITIAN(X,'skew')
%   ISHERMITIAN(X,'nonskew')
%   
%   Example:
%   spmd
%      T = codistributed(triu(gallery('moler',1000)));
%      X = T*(1+1i) - T'*(1-1i);
%      ISHERMITIAN(X)
%      ISHERMITIAN(X, 'skew')
%   end
%   
%   See also ISHERMITIAN, MAGIC, CODISTRIBUTED.
%   


%   Copyright 2014-2016 The MathWorks, Inc.

% This function works for numerics, logicals and chars
if ~isfloat(A) && ~islogical(A)
    error(message('MATLAB:isHermitian:inputType'))
end

if nargin<2
    skew = false;
else
    if ~isScalarString(skew) ...
            || ~ismember(upper(skew), {'SKEW', 'NONSKEW'})
        error(message('MATLAB:isHermitian:inputFlag'));
    end
    skew = strcmpi(skew, 'SKEW');
end

doConj = true;
tf = checkSymmetry( A, doConj, skew );

end


function tf = isScalarString(arg)
    tf = (ischar(arg) && isrow(arg)) || (isstring(arg) && isscalar(arg));
end