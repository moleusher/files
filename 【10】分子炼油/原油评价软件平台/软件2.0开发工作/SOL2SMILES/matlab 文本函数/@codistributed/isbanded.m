function res = isbanded( A, lower, upper )
%ISBANDED  Determine if  codistributed matrix is within specific bandwidth.
%   
%   TF = ISBANDED(A,LOWER,UPPER) returns logical 1 (true) if matrix A is 
%   within the specified lower bandwidth, LOWER, and upper bandwidth, UPPER; 
%   otherwise, it returns logical 0 (false).
%   
%   Example:
%   spmd
%      A = codistributed([2 3 0 0 ; 1 -2 -3 0; 0 -1 2 3 ; 0 0 -1 2]);
%      isbanded(A,1,1) % = 1
%      isbanded(A,0,1) % = 0
%   end
%   
%   See also ISBANDED, CODISTRIBUTED, CODISTRIBUTED/BANDWIDTH.
%   


%   Copyright 2015-2016 The MathWorks, Inc.

distributedutil.CodistParser.verifyNonCodistributedInputs({A, lower, upper});

% Gather the bandwidth params if they are distributed
lower = distributedutil.CodistParser.gatherIfCodistributed(lower);
upper = distributedutil.CodistParser.gatherIfCodistributed(upper);

% Test for validity
try
    iCheckBandwidthArg(lower);
    iCheckBandwidthArg(upper);
catch E
    throw(E);
end

% Call the normal MATLAB version if the data is on the host
if ~isa(A, 'codistributed')
    res = isbanded(A, lower, upper);
    return;
end

% This function works for numerics, logicals and chars
if ~(isnumeric( A ) || islogical( A ) || ischar( A ))
    error(message('parallel:distributed:InvalidType','isbanded',classUnderlying(A)));
end

% Always return false for ND arrays
if ~ismatrix( A )
    res = false;
    return;
end

codistr = getCodistributor( A );
LP = getLocalPart( A );
res = codistr.hBandwidthImpl( LP, lower, upper );

end

function iCheckBandwidthArg(k)
% Sanity check bandwidth argument
if ~isnumeric(k) || ~isscalar(k) || k<0 || k~=round(k)
    error(message('MATLAB:isbanded:nonNegIntScalar'));
end
end