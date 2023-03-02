function s = insertAfter(str, pos, text)
% INSERTAFTER Insert substring after a specified position
%    S = INSERTAFTER(STR, START_STR, NEW_TEXT) returns a string with the
%    content of STR where NEW_TEXT is inserted directly after every
%    occurrence of START_STR. S has the same dimensions as STR. START_STR
%    can be a string scalar or the same size as STR.
%
%    S = INSERTAFTER(STR, POS, NEW_TEXT) returns a string with the content
%    of STR where NEW_TEXT is inserted directly after numeric position POS.
%    POS must be an integer from 1 to the number of characters in a string
%    element.
%
%    NOTE: STR, START_STR, and NEW_TEXT can also be character vectors or
%    cell arrays of character vectors. The output S is the same data type
%    as STR.
%
%    Example:
%        str = "The quick fox";
%        insertAfter(str,'quick',' brown')
%
%        returns 
%
%            "The quick brown fox"
%
%    See also STRING/PLUS, INSERTBEFORE, REPLACE, REPLACEBETWEEN

%   Copyright 2016 The MathWorks, Inc.

    narginchk(3, 3);

    if ~isTextStrict(str)
        error(fillMessageHoles('MATLAB:string:MustBeCharCellArrayOrString',...
                               'MATLAB:string:FirstInput'));
    end

    try
        s = string(str);
        s = s.insertAfter(pos, text);
        
        if ischar(str)
            s = char(s);
        elseif iscell(str)
            s = cellstr(s);
        end
        
    catch ex
        if strcmp(ex.identifier, 'MATLAB:string:CannotConvertMissingElementToChar')
            error(fillMessageHoles('MATLAB:string:CannotInsertMissingIntoChar',...
                                   'MATLAB:string:MissingDisplayText'));
        end
        ex.throw;
    end
end
