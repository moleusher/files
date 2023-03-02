function ms = msRecur0(R)
if R ==0
    ms = [];
elseif R ==1
    ms = 'C';
else
    ms = [msRecur0(R-1),'C'];
end
     %return
end