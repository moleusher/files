function C = besselk(varargin)
%BESSELK Modified Bessel function of the second kind for codistributed arrays.
%       K = besselk(NU,Z)
%       K = besselk(NU,Z,SCALE)
%    
%       Class support for inputs NU and Z:
%          float: double, single
%   
%   Example:
%   spmd
%       z = rand(10, 1, 'codistributed');
%       nu = 0.5;
%       besselk(nu, z)
%   end
%   
%   See also BESSELK, CODISTRIBUTED.
%   
%   


%   Copyright 2013 The MathWorks, Inc.

C = codistributed.pBesselCommon( ...
    @besselk, 'MATLAB:besselk:ScaleNotZeroOrOne', varargin{:});
