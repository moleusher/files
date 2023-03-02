function hValidateAttributes( varargin )
%hValidateAttributes  validate attributes of a codistributed array
%   
%   hValidateAttributes(A,CLASSES,ATTRIBUTES)
%   hValidateAttributes(A,CLASSES,ATTRIBUTES,ARGINDEX)
%   hValidateAttributes(A,CLASSES,ATTRIBUTES,FUNCNAME)
%   hValidateAttributes(A,CLASSES,ATTRIBUTES,FUNCNAME,VARNAME)
%   hValidateAttributes(A,CLASSES,ATTRIBUTES,FUNCNAME,VARNAME,ARGINDEX)
%   
%   Example:
%   spmd
%       A = codistributed([ 1 2 3; 4 5 6 ]);
%       B = codistributed([ 7 8 9; 10 11 12]);
%       C = cat(3, A, B);
%       hValidateAttributes(C,{'numeric'},{'2d'},'my_func','my_var',2)
%   end
%   
%   See also: validateattributes
%   


%   Copyright 2014 The MathWorks, Inc.

try
    distributedutil.hValidateAttributes( varargin{:} );
catch e
    myId = 'MATLAB:validateattributes:';
    if strncmp( myId, e.identifier, length(myId) )
        % leave VALIDATEATTRIBUTES on the stack, because there was a misuse
        % of VALIDATEATTRIBUTES itself
        throw(e)
    else
        % strip VALIDATEATTRIBUTES off the stack so that the error looks like
        % it comes from the caller just as if it had hand-coded its input checking
        throwAsCaller( e )
    end
end

