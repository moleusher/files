function out = strrep(in, oldSubstr, newSubstr)
%STRREP  Replace string with another.
%   MODIFIEDSTR = STRREP(ORIGSTR,OLDSUBSTR,NEWSUBSTR)
%   
%   Note that ORIGSTR must be a codistributed array of strings or a cell array
%   of char vectors. OLDSUBSTR, NEWSUBSTR can be single strings or arrays
%   of strings of the same size as ORIGSTR.
%   
%   Example:
%   spmd
%       c_files = {'c:\cookies.m'; ...
%                  'c:\candy.m';   ...
%                  'c:\calories.m'};
%       c_files_d = codistributed(c_files);
%       d_files_d = strrep(c_files_d, 'c:', 'd:')
%   end
%   
%   See also STRREP, CODISTRIBUTED.
%   
%   


%   Copyright 2015-2016 The MathWorks, Inc.

narginchk(3, 3);

% We will use the standard element-wise helper to run the operation. This
% requires that all inputs are string arrays or cellstr so that the
% size comparison will work.
fcnName = 'strrep';
in = checkInput(in, fcnName);
oldSubstr = checkInput(oldSubstr, fcnName);
newSubstr = checkInput(newSubstr, fcnName);

out = codistributed.pElementwiseOp(@strrep, in, oldSubstr, newSubstr);
end


function S = checkInput(S, fcnName)
% Check an input is supported and is an array of strings or cellstr

if iscodistributed(S)
    % We only support arrays of strings (or cellstr) for distributed inputs
    if ~isStringArray(S)
        error(message('parallel:distributed:NotStringArray', upper(fcnName)));
    end
else
    % Non-distributed inputs should be cells for the elementwise helper
    if ischar(S)
        S = {S};
    end
end
end
