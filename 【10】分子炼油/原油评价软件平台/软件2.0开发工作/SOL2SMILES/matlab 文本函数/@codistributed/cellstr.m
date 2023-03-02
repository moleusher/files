function out = cellstr(in, varargin)
%CELLSTR Convert  to cell array of character vector
%   
%   C = CELLSTR(S)
%   
%   Supported syntaxes for CALENDARDURATION, DATETIME, DURATION:
%   C = CELLSTR(T)
%   C = CELLSTR(T,FMT)
%   C = CELLSTR(T,FMT,LOCALE)
%   
%   See also DATETIME/CELLSTR, CELLSTR.
%   


%   Copyright 2016 The MathWorks, Inc.

clz = classUnderlying(in);
switch clz
    case {'categorical', 'string'}
        % Simple element-wise
        narginchk(1,1);
        out = codistributed.pElementwiseOp(@cellstr,in);
        
    case {'datetime', 'duration', 'calendarDuration'}
        % Element-wise on first arg but bind in trailing args
        narginchk(1,3);
        out = codistributed.pElementwiseOp(@(x) cellstr(x, varargin{:}), in);
        
    case 'cell'
        % Cell arrays are handled elementwise but can throw if a worker
        % hits a cell that is not a char vector or string.
        narginchk(1,1);
        out = codistributed.pElementwiseUnaryOpWithCatch(@cellstr,in);
        
    case 'char'
        % CELLSTR converts each row into one cell, i.e. it acts "slice-wise".
        narginchk(1,1);
        out = codistributed.pSlicewiseOp(@cellstr,in);
        
    otherwise
        error(message('parallel:array:UnsupportedFunction', upper(mfilename), clz));
end

end
