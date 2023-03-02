function d = calendarDuration(varargin)
%CALENDARDURATION Create an array of codistributed CALENDARDURATIONs.
%   
%   D = CALENDARDURATION(DV)
%   D = CALENDARDURATION(Y,MO,D)
%   D = CALENDARDURATION(Y,MO,D,H,MI,S)
%   D = CALENDARDURATION(...,'Format',FMT)
%    
%   See also CALENDARDURATION, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

d = codistributed.pDatetimeDurationCommon(@calendarDuration, 3, varargin{:});
