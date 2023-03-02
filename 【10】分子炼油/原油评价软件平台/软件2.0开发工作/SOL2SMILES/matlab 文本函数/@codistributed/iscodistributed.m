function tf = iscodistributed( ~ )
%ISCODISTRIBUTED True for a codistributed array
%   TF = ISCODISTRIBUTED( X ) returns true for a codistributed array and false
%   otherwise
%   
%   Example:
%   spmd
%     N = 1000;
%     D = codistributed.ones( N );
%     t = iscodistributed( D ) % returns t = true
%     f = iscodistributed( N )   % returns f = false
%   end
%   f = iscodistributed( D ) % returns f = false - D is now distributed
%   
%   See also CODISTRIBUTED, DISTRIBUTED, ISDISTRIBUTED, ISREPLICATED.
%   


%   Copyright 2009-2011 The MathWorks, Inc.

tf = true;

end
