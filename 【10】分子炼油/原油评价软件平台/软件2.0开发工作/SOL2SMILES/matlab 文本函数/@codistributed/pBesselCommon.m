function y = pBesselCommon(fcn, err, nu, z, scale)
%pBesselCommon Common logic for all codistributed Bessel functions
%   Y = codistributed.pBesselCommon(FCN, ERR, NU, Z, SCALE) performs some input
%   checking and throws ERR if parameters are not scalar. It then calls FCN
%   with the relevant arguments.


%   Copyright 2013-2014 The MathWorks, Inc.

narginchk(4, 5); % Scale is optional

% The SCALE parameter should be scalar and can be gathered.
% NU and Z are both "data" so we use the binary op helper.

% If provided, check SCALE is scalar before gathering
if nargin>4
    if ~isscalar(scale)
        error(message(err));
    end
    scale = distributedutil.CodistParser.gatherIfCodistributed(scale);
    
    fcncall = @(a,b) fcn(a, b, scale);
else
    fcncall = fcn;
end
 
try
    y = codistributed.pElementwiseOp(fcncall, nu, z);
    return;
catch E
    throwAsCaller(E);
end

