function S = pad(M, varargin)
%PAD Inserts leading and trailing characters.
%   S = PAD(M)
%   S = PAD(M, WIDTH)
%   S = PAD(M, WIDTH, SIDE)
%   S = PAD(M, WIDTH, SIDE, PadCharacter)
%   
%   See also PAD, TALL/STRING.
%   


%   Copyright 2016 The MathWorks, Inc.

% If padding width is not specified, we need to determine it from the max
% string length
if nargin<2 || ~isnumeric(varargin{1})
    if isempty(M)
        width = 1;
    else
        l = strlength(M);
        width = gather(max(iColonize(l)));
    end
    args = [{width}, varargin];
else
    args = varargin;
end

% Non-string cells or missing string elements can cause one worker to error.
% To avoid stalls we must make sure all workers throw in this case.
S = distributedutil.syncOnError( ...
    @() codistributed.pElementwiseUnaryOp(@pad, M, args{:}) );


function x = iColonize(x)
% Convert an ND array into a column vector
x = reshape(x,numel(x),1);
