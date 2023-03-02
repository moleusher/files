function tmpl = getTableTemplate(T)
% getTableTemplate  return a replicated empty table based on a distributed input table

%   Copyright 2016 The MathWorks, Inc.

% See if we already know the answer
if T.Metadata.TableTemplate.isKnown()
    % Get the answer from metadata
    tmpl = T.Metadata.TableTemplate.get();
    
else
    % Calculate the answer
    tmpl = distributedutil.getTableTemplate(T);
    % store back into metadata so we don't have to calculate it again
    T.Metadata.TableTemplate.set(tmpl);
    
end

end
