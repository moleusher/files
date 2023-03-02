function D = string(A, varargin)
%STRING Convert codistributed array to a string
%   S = STRING(X)
%   
%   Example:
%   spmd
%       N = 1000;
%       Du = codistributed.ones(N,'uint32');
%       Ds = string(Du)
%       classDu = classUnderlying(Du)
%       classDs = classUnderlying(Ds)
%   end
%   
%   See also STRING, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2016 The MathWorks, Inc.

if ischar(A)
    % Char is special, so use a helper.
    narginchk(1,1);
    D = iChar2String(A);
    
elseif isdatetime(A) || isduration(A) || iscalendarduration(A)
    % Datetime family allows format and locale trailing args. Element-wise
    % in the first input, the rest are broadcast.
    narginchk(1,3);
    D = codistributed.pElementwiseUnaryOp(@string, A, varargin{:});
    
else
    % For everything else this is unary elementwise
    narginchk(1,1);
    D = codistributed.pElementwiseUnaryOp(@string, A);
    
end
end % string

function D = iChar2String(A)
% Convert a char array into a string array. This behaves very differently
% to all other types since the second dimension collapses.

% take special care over '' (0x0 char)
if isequal(size(A), [0 0])
    D = codistributed.pConstructFromReplicated(string(''));
    return
end

% For char arrays, we need to turn each row into a separate string. if
% we are distributed in the second dimension we must redistribute to
% avoid losing all parallelism.
A = iMaybeRedistribute(A);

A_lp = getLocalPart(A);
A_codistr = getCodistributor(A);

out_lp = string(A_lp);

% Output is same size as input except that the second dimension is
% deleted.
out_size = size(A);
out_size(2) = [];
if length(out_size)<2
    out_size(2) = 1;
end
if A_codistr.Dimension > 2
    out_distdim = A_codistr.Dimension - 1;
else
    out_distdim = A_codistr.Dimension;
end

out_codistr = codistributor1d(out_distdim, A_codistr.Partition, out_size);

% Build the output
D = codistributed.pDoBuildFromLocalPart(out_lp, out_codistr); %#ok<DCUNK> Calling a private static method.
end

function A = iMaybeRedistribute(A)
% Make sure A has a 1D distribution but with whole rows
codistr = getCodistributor(A);
if ~isa(codistr, 'codistributor1d') || codistr.Dimension==2
    if ismatrix(A)
        dim = 1;
    else
        dim = ndims(A);
    end
    newCodistr = codistributor('1d',dim,codistributor1d.defaultPartition(size(A,dim)));
    A = redistribute(A, newCodistr);
end
end
