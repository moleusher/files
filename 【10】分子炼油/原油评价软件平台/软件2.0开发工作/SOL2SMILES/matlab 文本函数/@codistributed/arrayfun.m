function varargout = arrayfun(varargin)
%ARRAYFUN Apply a function to each element of codistributed array
%   A = ARRAYFUN(FUN, B) applies the function specified by FUN to each element
%   of the codistributed array B, and returns the results in codistributed array
%   A.  The array A is the same size as B, and the (I,J,...)th element of A is 
%   equal to FUN(B(I,J,...)). FUN is a function handle to a function that takes
%   one input argument and returns a scalar value. FUN must return values of 
%   the same class each time it is called.  The order in which ARRAYFUN computes
%   elements of A is not specified and should not be relied on.
%   
%   A = ARRAYFUN(FUN, B, C,  ...) evaluates FUN using elements of the arrays
%   B, C,  ... as input arguments.  The (I,J,...)th element of the
%   codistributed array A is equal to FUN(B(I,J,...), C(I,J,...), ...).  
%   All input arguments must be of the same size.
%   
%   [A, B, ...] = ARRAYFUN(FUN, C, ...), where FUN is a function handle
%   to a function that returns multiple outputs, returns codistributed arrays
%   A, B,..., each corresponding to one of the output arguments of FUN.  ARRAYFUN
%   calls FUN each time with as many outputs as there are in the call to ARRAYFUN.
%   FUN can return output arguments having different classes, but the class of
%   each output must be the same each time FUN is called. This means that all
%   elements of A must be the same class; B can be a different class from A, but
%   all elements of B must be of the same class.
%   
%   [A, ...] = arrayfun(FUN, B,  ..., 'Param1', val1, ...) enables you to
%   specify optional parameter name/value pairs.  Parameters are:
%   
%      'UniformOutput' -- a logical value indicating whether or not the
%      output(s) of FUN can be returned without encapsulation in a cell
%      array. If true (the default), FUN must return scalar values that can
%      be concatenated into an array; the outputs must be of the 
%      following types:  numeric, logical, char, struct, cell.  If false, 
%      arrayfun returns a cell array (or multiple cell arrays), where the 
%      (I,J,...)th cell contains the value FUN(B(I,J,...), ...); and
%      the outputs can be of any type.
%    
%      'ErrorHandler' -- a function handle, specifying the function
%      MATLAB is to call if the call to FUN fails.   The error handling
%      function will be called with the following input arguments:
%        -  a structure, with the fields:  "identifier", "message", and
%           "index", respectively containing the identifier of the error
%           that occurred, the text of the error message, and the linear 
%           index into the input array(s) for which the error occurred. 
%        -  the set of input arguments for which the call to the function
%           failed.
%    
%      The error handling function should either rethrow an error, or
%      return the same number of outputs as FUN.  These outputs are then
%      returned as the outputs of arrayfun.  If 'UniformOutput' is true,
%      the outputs of the error handler must also be scalars of the same
%      type as the outputs of FUN. Example:
%    
%      function [A, B] = errorFunc(S, varargin)
%          warning(S.identifier, S.message); A = NaN; B = NaN;
%    
%      If an error handler is not specified, the error from the call to 
%      FUN will be rethrown.
%   
%   Examples
%   If the MATLAB function aFunction is defined as follows:
%   function [o1, o2] = aFunction(a, b, c)
%       o1 = a + b;
%       o2 = o1 .* c + 2;
%     
%   Then this can be executed as follows:
%   spmd
%       N = 1000;
%       s1 = codistributed.rand(N);
%       s2 = codistributed.rand(N);
%       s3 = codistributed.rand(N);
%       [o1, o2] = arrayfun(@aFunction, s1, s2, s3)
%   end
%   
%   See also  ARRAYFUN, CODISTRIBUTED, function_handle, gather


%   Copyright 2010-2013 The MathWorks, Inc.

narginchk(2, Inf);
isCellfun = false;
[varargout{1:max(1, nargout)}] = codistributed.pCellfunAndArrayfun(...
    isCellfun, varargin); %#ok<DCUNK>

end % End of arrayfun.
