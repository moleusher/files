function C = convTrimResult(C,szA,szB,isSame,isValid)
% Helper to trim the result based on the shape input

% Copyright 2016 The MathWorks, Inc.

szC = size(C);
index = cell(1,ndims(C));

if isValid
    for i = 1:ndims(C)
        index{i} = szB(i):szC(i)+1-szB(i);
    end
    C = subsref(C,struct('type','()','subs',{index}));

elseif isSame
    % Match size of A
    offset = floor(szB/2);

    for i = 1:ndims(C)
        index{i} = offset(i) + (1:szA(i));
    end

    C = subsref(C,struct('type','()','subs',{index}));

else
    % Full, so nothing to trim
end
end