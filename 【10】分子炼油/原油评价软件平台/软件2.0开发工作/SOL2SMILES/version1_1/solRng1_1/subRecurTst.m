% �ݹ��㷨�����֧����ȡ����
% Rc = R - br ʣ��̼
dc = subRecur(3,4)

function sub = subRecur(Rc,brc)
    if brc == 1
        smlp = msRecur(Rc);
        sub = [smlp,'(C)'];  
    elseif (Rc-1)>brc % �����ͷ�ļ׻�̼��ֻ��Rc-1����̼������̼����brc,��brc����̼���Ա�Ϊ��̼��ʣ��Rc-brc-1Ϊ��̼,���һ�����ǲ�̼
        smlc = mscRecur(brc);
        smlp = msRecur(Rc-brc);
        sub = [smlp,smlc];
    else % Rc-1 ��̼С��brc������brc-(Rc-1)����̼���Ϊ��̼
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
