function tf = iscellstr(X)
%ISCELLSTR True for codistributed cell array of strings
%     TF = ISCELLSTR(X)
%     
%     Example:
%     spmd
%         N = 1000;
%         A = cellstr(repmat('a', N, 1));
%         D = codistributed(A);
%         tf = iscellstr(D);
%     end
%     
%     returns tf = true.
%     
%     See also ISCELLSTR, CELLSTR, REPMAT, CODISTRIBUTED.


%   Copyright 2011 The MathWorks, Inc.

% Check that iscellstr is true on all processors.

xDist = getCodistributor(X);
localX = getLocalPart(X);

tf = xDist.hIscellstrImpl(localX);