function varargout = unwrap(varargin)
%UNWRAP Unwrap phase angle.
%   Q = UNWRAP(P)
%   Q = UNWRAP(P,TOL)
%   Q = UNWRAP(P,[],DIM)
%   Q = UNWRAP(P,TOL,DIM)
%   
%   Example:
%   spmd
%       % Create a sawtooth phase signal wrapping from +pi to -pi
%       noise = rand(1, 10000, 'codistributed') - 0.5;
%       P = repmat(codistributed.linspace(-pi, pi, 1000), 1, 10) + noise;
%   
%       % Unwrap to retrieve linear trend
%       Q = unwrap(P);
%   end
%   
%   See also UNWRAP, CODISTRIBUTED, CODISTRIBUTED/ANGLE, CODISTRIBUTED/ABS.


%   Copyright 2014 The MathWorks, Inc.

% try...catch prevents error being reported by internal
try
    [varargout{1:nargout}] = parallel.internal.flowthrough.unwrap(varargin{:});
catch ME
    throw(ME);
end
