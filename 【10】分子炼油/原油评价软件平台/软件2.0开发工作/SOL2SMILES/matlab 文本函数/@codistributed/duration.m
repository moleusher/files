function d = duration(varargin)
%DURATION Create an array of codistributed durations.
%   
%   D = DURATION(DV)
%   D = DURATION(H,MI,S)
%   D = DURATION(H,MI,S,MS)
%   D = DURATION(...,'Format',FMT)
%    
%   See also DURATION, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

d = codistributed.pDatetimeDurationCommon(@duration, 3, varargin{:});
