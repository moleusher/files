function pVerifyUsing1d(methodName, varargin)
%pVerifyUsing1d Assert that codistributed arrays are using codistributor1d


%   Copyright 2009-2012 The MathWorks, Inc.

if ~all(cellfun(@iIsSupported, varargin))
    if strcmp(lower(methodName), methodName)
        % All in lower case, so display in upper case.
        dispName = upper(methodName);
    else
        % Method name contains mixed case, so display in mixed case.
        dispName = methodName;
    end
    E = MException(message('parallel:distributed:CodistributorNotSupported', ...
                           dispName));
    throwAsCaller(E);
end

end % End of pVerifyUsing1d.


    
function ok = iIsSupported(X)
    ok = true;
    if isa(X, 'codistributed') && ~isa(getCodistributor(X), 'codistributor1d')
       ok = false;
    end
end
