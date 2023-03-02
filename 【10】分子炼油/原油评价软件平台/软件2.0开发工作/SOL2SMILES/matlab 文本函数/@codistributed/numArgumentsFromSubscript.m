function sz = numArgumentsFromSubscript(t, s, context)
%numArgumentsFromSubscript Overloaded for codistributed array arrays.
%   


%   Copyright 2016 The MathWorks, Inc.

if isscalar(s)
    sz = 1; % codistributed (incl. table) returns one array for parens, braces, and dot
            % If we supported brace indexing on a cell array, we'd have to change that.

elseif context == matlab.mixin.util.IndexingContext.Assignment
    sz = 1; % codistributed subsasgn only ever accepts one rhs value
    
elseif strcmp(s(end).type,'()')
    % This should never be called with parentheses as the last
    % subscript, but return 1 for that just in case
    sz = 1;
    
else % multiple subscripting levels
     % perform one level of indexing, then forward result to builtin numArgumentsFromSubscript
    x  = subsref(t, s(1));
    sz = numArgumentsFromSubscript(x,s(2:end),context);
end
end
