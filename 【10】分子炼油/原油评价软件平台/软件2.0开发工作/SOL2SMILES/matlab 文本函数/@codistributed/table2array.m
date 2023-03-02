function a = table2array(t)
%TABLE2ARRAY Convert codistributed table to a homogeneous array.
%   A = TABLE2ARRAY(T)
%   
%   See also TABLE2ARRAY, CODISTRIBUTED.
%   


%   Copyright 2016 The MathWorks, Inc.

if ~istable(t)
    error(message('parallel:array:UnsupportedFunction', upper(mfilename), classUnderlying(t)));
end

% Table variables are not necessarily columns. The number of rows is
% preserved but other dimensions might not be. We therefore ensure we are
% distributed in the first dimension before trying to process.
t = iEnsureRowDistribution(t);

t_lp = getLocalPart(t);
t_codistr = getCodistributor(t);

% Process the local part, making sure any errors are thrown collectively.
a_lp = distributedutil.syncOnError(@table2array, t_lp);

% Work out the new global size and partition. We can avoid communication
% because we are distributed in the first dimension and table2array
% preserves the number of rows. The other dimensions are expanded the same
% way for every local part.
dim = t_codistr.Dimension;
part = t_codistr.Partition;
gsize = size(a_lp);
gsize(dim) = sum(part);
a_codistr = codistributor1d(dim, part, gsize);

% Now build the output
a = codistributed.pDoBuildFromLocalPart(a_lp, a_codistr); %#ok<DCUNK>

end

function t = iEnsureRowDistribution(t)
% Ensure that workers have complete rows of the table
codistr = getCodistributor(t);
if ~isa(codistr, 'codistributor1d') || codistr.Dimension~=1
    t = redistribute(t, codistributor('1d',1));
end
end
