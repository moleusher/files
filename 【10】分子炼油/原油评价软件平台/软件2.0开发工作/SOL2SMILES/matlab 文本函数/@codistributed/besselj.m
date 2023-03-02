function C = besselj(varargin)
%BESSELJ Bessel function of the first kind for codistributed arrays.
%       J = BESSELJ(NU,Z)
%       J = besselj(NU,Z,SCALE)
%   
%       Class support for inputs NU and Z:
%          float: double, single
%   
%   Example:
%   spmd
%       z = rand(10, 1, 'codistributed');
%       nu = 1;
%       besselj(nu, z)
%   end
%   
%   See also BESSELJ, CODISTRIBUTED.


%   Copyright 2013 The MathWorks, Inc.

C = codistributed.pBesselCommon( ...
    @besselj, 'MATLAB:besselj:ScaleNotZeroOrOne', varargin{:});


