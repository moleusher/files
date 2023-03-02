function tf = iscategory(a, catStr)
%ISCATEGORY Test for categorical array categories.
%   
%   TF = ISCATEGORY(A,CATEGORIES)
%    
%   See also CATEGORICAL/ISCATEGORY, codistributed.
%   


%   Copyright 2016 The MathWorks, Inc.

narginchk(2,2);

% Make sure cat is not distributed
catStr = distributedutil.CodistParser.gatherIfCodistributed(catStr);
% If a wasn't distributed, just do it on the client
if ~isa(a, 'codistributed')
    tf = iscategory(a, catStr);
    return;
end

% Simply compare the list of categories (which is replicated) with the
% inputs categories (also replicated). The result is elementwise in CATSTR.
catlist = categories(getLocalPart(a));
tf = ismember(catStr, catlist);
