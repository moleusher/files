function C = bessely(varargin)
%BESSELY Bessel function of the second kind for codistributed arrays.
%       Y = BESSELY(NU,Z)
%       Y = bessely(NU,Z,SCALE)
%   
%       Class support for inputs NU and Z:
%          float: double, single
%   
%   Example:
%   spmd
%       z = rand(10, 1, 'codistributed');
%       nu = 1;
%       bessely(nu, z)
%   end
%   
%   See also BESSELY, CODISTRIBUTED.


%   Copyright 2013 The MathWorks, Inc.

C = codistributed.pBesselCommon( ...
    @bessely, 'MATLAB:bessely:ScaleNotZeroOrOne', varargin{:});
