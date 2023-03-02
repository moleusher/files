function C = besselh(nu, varargin)
%BESSELH Bessel function of the third kind (Hankel function) for codistributed arrays.
%       H = besselh(NU,Z)
%       H = besselh(NU,K,Z)
%       H = besselh(NU,K,Z,SCALE)
%   
%       Class support for inputs NU and Z:
%          float: double, single
%       
%   Example:
%   spmd
%       [X,Y] = meshgrid(-4:0.025:2,-1.5:0.025:1.5);
%       Z = codistributed(X+iY);
%       H = besselh(0,1,Z);
%   end
%   
%   See also BESSELH, CODISTRIBUTED.
%   
%   


%   Copyright 2013-2014 The MathWorks, Inc.

narginchk(2,4);

% The K and SCALE parameters are scalars and should always be gathered.
% NU and Z are both "data" so we use the binary op helper.

if (nargin==2)
   % besselh(NU,Z)
    z = varargin{1};
    fcn = @besselh;
else
    z = varargin{2};

    % Check K is scalar before gathering
    if ~isscalar(varargin{1})
        error(message('MATLAB:besselh:KNotOneOrTwo'));
    end
    k = distributedutil.CodistParser.gatherIfCodistributed(varargin{1});
    
    % If provided, check SCALE is scalar before gathering
    if nargin>3
        if ~isscalar(varargin{3})
            error(message('MATLAB:besselh:ScaleNotZeroOrOne'));
        end
        scale = distributedutil.CodistParser.gatherIfCodistributed(varargin{3});
    else
        scale = 0;
    end
    
    fcn = @(a,b) besselh(a, k, b, scale);
end
 
C = codistributed.pElementwiseOp(fcn, nu, z);

