function varargout = bandwidth( A, whichOutput )
%BANDWIDTH  Return the lower and upper bandwidth of a codistributed matrix.
%   
%   [LOWER,UPPER] = bandwidth(X)
%   LOWER = bandwidth(X,'lower')
%   UPPER = bandwidth(X,'upper')
%   
%   Example:
%   spmd
%      A = codistributed([2 3 0 0 ; 1 -2 -3 0; 0 -1 2 3 ; 0 0 -1 2]);
%      [lower, upper] = bandwidth(A,1,1) % = 1, 1
%   end
%   
%   See also ISBANDED, CODISTRIBUTED, CODISTRIBUTED/ISBANDED.
%   


%   Copyright 2016 The MathWorks, Inc.

% Check nargin and nargout match
if nargin == 1
    nargoutchk(1,2);
else
    nargoutchk(1,1);
end

% This function works for numerics, logicals and chars
if ~(isnumeric( A ) || islogical( A ) || ischar( A ))
    error(message('parallel:distributed:InvalidType','bandwidth',classUnderlying(A)))
end

% Also error for ND arrays
if ~ismatrix( A )
    error(message('MATLAB:bandwidth:inputMustBe2D'));
end

codistr = getCodistributor( A );
LP = getLocalPart( A );
[~, lower, upper] = codistr.hBandwidthImpl( LP );

% Handle optional second argument
if nargin == 2
    if strcmpi(whichOutput, 'lower')
        varargout{1} = lower;
    elseif strcmpi(whichOutput, 'upper')
        varargout{1} = upper;
    else
        error(message('MATLAB:bandwidth:unknownArgument'));
    end
else
    [varargout{1:2}] = deal(lower, upper);
end

end