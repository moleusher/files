function [sendStages, sendQty] = convSendStages(thisIndex,endIndex,part,n)
% For CONV and CONV2, determine which workers to send data to and how much
% data to send.

% Copyright 2015 The MathWorks, Inc.

if thisIndex ~= endIndex && part(thisIndex) ~= 0
    cumSum = cumsum(part(thisIndex+1:end));
    x = find(cumSum >= n);
    sendStages = [];
    sendQty = [];
    if ~isempty(x)
        lastStage = x(1);
    else
        lastStage = endIndex-thisIndex;
    end
    
    totalSend = n;
    for i = thisIndex+1:thisIndex+lastStage
        if part(i)~= 0
            sendStages(end + 1) = i; %#ok<AGROW>
            sendQty(end + 1) = min(totalSend, part(thisIndex)); %#ok<AGROW>
            totalSend = n - sum(part(thisIndex+1:i));
        end
    end
else
    sendStages = [];
    sendQty = 0;
end
end