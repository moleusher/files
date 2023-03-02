function E = dispatchUndefinedFunctionException(E)
%dispatchUndefinedFunctionException transform MATLAB:UndefinedFunction
%   Modifies exceptions with identifier MATLAB:UndefinedFunction to remove the
%   arguments so as to avoid triggering auto-attach-files for (co)distributed
%   methods. This exception dispatch method should be used like so:
%
%   try
%      out = someFcn(in);
%   catch E
%      throw(dispatchUndefinedFunctionException(E))
%   end
%
%   NB: It should be used only when 'someFcn' is known to be an existing MATLAB
%   function (i.e. it should never be used for user-supplied functions), and
%   therefore MATLAB:UndefinedFunction can only be emitted by 'someFcn' in the
%   case where there is no method 'someFcn' for data of the type of 'in'. See
%   g1389042 for details.

% Copyright 2016 The MathWorks, Inc.

if strcmp(E.identifier, 'MATLAB:UndefinedFunction')
    % By creating a new MException here with no arguments, we foil the attempts made
    % by missingSourcesFromException to discover what the UndefinedFunction was
    % called.
    E = MException('MATLAB:UndefinedFunction', '%s', E.message);
end
end
