function receiveFrom = convReceiveStages(thisIndex, startDim, part, n)
% For CONV and CONV2, determine which workers to receive data from and
% whether to pad with zeros.

% Copyright 2015 The MathWorks, Inc.

% startLab does not receive any data and endLab does not send any data.
% The other labs receive data up to maxSend in size. All labs receive
% from labs with lower lab indices. If the amount of data in the workers
% with lower lab indices sums to less than maxSend, then the lab gets
% all the data from the preceding labs.
% The other labs send data up to maxSend in size. If the lab does not
% have maxSend amount, it sends its length. The labs send data to all
% labs with greater lab indices that require it.

stages = 1;
sumTotal = 0;
receiveFrom = [];
if thisIndex ~= startDim
    while sumTotal < n
        nextLab = (thisIndex - stages);
        if nextLab < startDim
            break
        end
        sumTotal = sumTotal + part(nextLab);
        stages = stages + 1;
        if part(nextLab) ~= 0
            receiveFrom(end + 1) = nextLab; %#ok<AGROW>
        end
    end
end
end
