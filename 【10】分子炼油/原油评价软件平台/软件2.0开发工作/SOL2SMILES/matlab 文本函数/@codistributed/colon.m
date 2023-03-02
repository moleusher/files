function D = colon(a, varargin)
%CODISTRIBUTED.COLON Build codistributed array equivalent to A:B or A:D:B
%   C = CODISTRIBUTED.COLON(A,B)
%   C = CODISTRIBUTED.COLON(A,D,B)
%   
%   CODISTRIBUTED.COLON has additional optional arguments, specified after B
%   as follows:
%   
%   C = CODISTRIBUTED.COLON(...,CODISTR)
%   C = CODISTRIBUTED.COLON(...,'noCommunication')
%   C = CODISTRIBUTED.COLON(...,CODISTR,'noCommunication')
%   
%     CODISTR - A codistributor object specifying the distribution scheme of
%     the resulting array.  If omitted, the array is distributed using the
%     default distribution scheme.
%   
%     'noCommunication' - Specifies that no communication is to be performed
%     when constructing the array, skipping some error checking steps.
%   
%   Example:
%   spmd
%       N = 1000;
%       C = codistributed.colon(1,N) % Distributes vector 1:N over the workers
%   end
%   
%   See also COLON, CODISTRIBUTED.


%   Copyright 2008-2014 The MathWorks, Inc.

narginchk(2, 5);

distributedutil.CodistParser.verifyNonCodistributedInputs([{a}, varargin]);

try
    [a, d, b, codistr, allowCommunication] = iParseArgs(a, varargin{:});
    if allowCommunication
        % Don't display CODISTRIBUTED.COLON to users because they might arrive here
        % via the colon overloads on codistributor1d and 2dbc.
        distributedutil.CodistParser.verifyReplicatedInputArgs('colon', ...
                                                          {a, d, b, codistr});
    end
catch e
    throw(e);
end

[LP, codistr] = codistr.hColonImpl(a, d, b);
% We have already verified that a, d, and b are called collectively, so no
% further error checking is necessary.
D = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK> private static.

end % End of codistributed.colon.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a, d, b, codistr, allowCommunication] = iParseArgs(a, varargin)
% iParseArgs Input should be input arguments 2 to end of the input arguments to
% codistributed.colon.

% First, identify all uses of 'noCommunication' and specifications of
% codistributors at the end of the argument list.
argList = varargin;
[argList, allowCommunication] = distributedutil.CodistParser.extractCommFlag(argList);
[argList, codistr] = distributedutil.CodistParser.extractCodistributor(argList);

if isempty(argList)
    error(message('parallel:distributed:ColonNoEndpoint')); 
end

% The only remaining options are:
% {b}
% {d, b}
switch length(argList)
  case 1
    % argList must be {b}.
    d = 1;
    b = argList{1};
  case 2
    % argList must be {d, b} 
    d = argList{1};
    b = argList{2};
  otherwise
    % argList{3} and up were invalid.
    error(message('parallel:distributed:ColonInvalidArgs'));
end
if ~allowCommunication
    distributedutil.CodistParser.verifyNotCodistWithNoComm('colon', ...
                                                      {a, b, d});
end

a = distributedutil.CodistParser.gatherIfCodistributed(a);
b = distributedutil.CodistParser.gatherIfCodistributed(b);
d = distributedutil.CodistParser.gatherIfCodistributed(d);

% Verify the values of a, d and b.  We make more stringent requirements than the
% built-in colon as we only support integer and float scalars.  This leaves out
% all the oddities with chars, char arrays, vectors, and complex values.
isValidNumericLike = @(x) isinteger(x) || isfloat(x);
if isValidNumericLike(a)  ...
        && isValidNumericLike(b) ...
        && isValidNumericLike(d)
    a = a(1);
    b = b(1);
    d = d(1);
else
    error(message('parallel:distributed:ColonInvalidStartEnd'));
end

end % End of iParseArgs.
