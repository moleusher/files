% ���컷������ϩ��
function naph = soln2smn(ncarb,solvec)
% if N6 n5  ����һ�����ִ���0
if solvec(:,4)>0 || solvec(:,5)> 0
    % ���컷��������
    naphem = solp2smlp(ncarb-2,'c');
    naph_t = ['c1',naphem,'c1'];
    nR = solvec(10);
    if solvec(10)>0 && solvec(11)==0
        rchain = solp2smlp(solvec(10));%����ֱ�������԰��ⲿ��ģ�黯
       naph_t = insertBefore(naph_t,1,rchain); 
    elseif solvec(10)>0 && solvec(11)>0
        rchain=soli2smli(solvec(10),solvec(11));
        naph_t = insertBefore(naph_t,1,rchain);
    end
    nme = solvec(12); % ���ϼ׻�����
    if nme>0 % ���жϻ��ϼ׻���λ��
        for i = 1:nme
            mchain = insertAfter(naph_t,2+(i-1).*4,'c');% ??
            naph_t = mchain;
        end
        if solvec(11)>0
           ccarb = solvec(10)-nme;% ȥ�����ϵļ׻�
           isop = soli2smi(ccarb,solvec(11));
           naph_t = insertBefore(naph_t,1,isop);
        end
    end
else
    % ϩ��
    % �ڱ�����SML�Ļ���������˫��
    mch = solismi(carb,solvec(11)); % ����������SMILES
    len = length(mch);
    naph_t = insertAfter(mch,len-1,'=');
end
naph = naph_t;
end