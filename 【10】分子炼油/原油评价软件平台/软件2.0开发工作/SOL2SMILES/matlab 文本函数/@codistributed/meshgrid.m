function varargout = meshgrid(varargin)
%MESHGRID Generate codistributed arrays for 2-D functions and 3-D surface plots.
%   [X,Y] = MESHGRID(x,y)
%   [X,Y] = MESHGRID(x) is the same as [X,Y] = MESHGRID(x,x)
%   [X,Y,Z] = MESHGRID(x,y,z)
%   [X,Y,Z] = MESHGRID(x) is the same as [X,Y,Z] = MESHGRID(x,x,x)
%   
%   Class support for inputs:
%          float: double, single
%   
%   Example:
%   spmd
%            N = 1000;
%            x = codistributed.ones(N, 1);
%            y = codistributed.rand(2*N,1);
%            [X, Y] = meshgrid(x, y);
%   end
%   
%   See also MESHGRID, CODISTRIBUTED, CODISTRIBUTED/ONES.


%   Copyright 2010-2012 The MathWorks, Inc.

narginchk(1, 3);
nargoutchk(0, 3);

if (nargin > 1) && (nargin < nargout)
    error(message('parallel:distributed:MeshgridNotEnoughInputs'));
end

isInputFloat = cellfun(@(x)distributedutil.CodistParser.isa(x, 'float'), ...
                       varargin);
if ~all(isInputFloat)
    error(message('parallel:distributed:MeshgridOnlySupportFloat'));
end

numOut = max(2, nargout);
if nargin == 1
    varargin = repmat(varargin, 1, numOut);
else
    varargin = iConvertBetweenMeshgridAndNdgrid( varargin );
end

% Get results from ndgrid
[varargout{1:numOut}] = ndgrid(varargin{:});
varargout = iConvertBetweenMeshgridAndNdgrid( varargout );

end % End of meshgrid.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cellOfOutputs = iConvertBetweenMeshgridAndNdgrid( cellOfInputs )
    cellOfOutputs = cellOfInputs;        % copy all
    cellOfOutputs{1} = cellOfInputs{2};  % swap first two
    cellOfOutputs{2} = cellOfInputs{1};
end
