% 递归算法构造带支链的取代基
% Rc = R - br 剩余碳
dc = subRecur(3,4)

function sub = subRecur(Rc,brc)
    if brc == 1
        smlp = msRecur(Rc);
        sub = [smlp,'(C)'];  
    elseif (Rc-1)>brc % 不算端头的甲基碳，只有Rc-1个仲碳，若仲碳大于brc,则brc个仲碳可以变为叔碳，剩余Rc-brc-1为仲碳,最后一个还是伯碳
        smlc = mscRecur(brc);
        smlp = msRecur(Rc-brc);
        sub = [smlp,smlc];
    else % Rc-1 仲碳小于brc，则有brc-(Rc-1)个仲碳需变为季碳
        mscd = mscdRecur(brc-(Rc-1));
        fbrc = brc - 2*(brc-(Rc-1));
        if fbrc > 0
            smlc = mscRecur(fbrc);
        else
            smlc = [];
        end
        smlp = msRecur(1); 
        sub = [smlp,smlc,mscd];  
    end

end
function ms = msRecur(R)
     if R ==1
         ms = 'C';
     else
         ms = [msRecur(R-1),'C'];
     end
     %return
end
function msc = mscRecur(R)
     if R ==1
         msc = 'C(C)';
     else
         msc = [mscRecur(R-1),'C(C)'];
     end
end
function mscd = mscdRecur(R)
     if R ==1
         mscd = 'C(C)(C)';
     else
         mscd = [mscdRecur(R-1),'C(C)(C)'];
     end
end
