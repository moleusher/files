function C = besseli(varargin)
%BESSELI Modified Bessel function of the first kind for codistributed arrays.
%       I = besseli(NU,Z)
%       I = besseli(NU,Z,SCALE)
%    
%       Class support for inputs NU and Z:
%          float: double, single
%   
%   Example:
%   spmd
%       z = rand(10, 1, 'codistributed');
%       nu = 0.5;
%       besseli(nu, z)
%   end
%   
%   See also BESSELI, CODISTRIBUTED.
%   
%   


%   Copyright 2013 The MathWorks, Inc.

C = codistributed.pBesselCommon( ...
    @besseli, 'MATLAB:besseli:ScaleNotZeroOrOne', varargin{:});
