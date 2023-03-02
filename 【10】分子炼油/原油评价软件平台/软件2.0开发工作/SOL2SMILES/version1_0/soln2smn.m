% 构造环烷烃和烯烃
function naph = soln2smn(ncarb,solvec)
% if N6 n5  任意一个数字大于0
if solvec(:,4)>0 || solvec(:,5)> 0
    % 构造环烷烃主链
    naphem = solp2smlp(ncarb-2,'c');
    naph_t = ['c1',naphem,'c1'];
    nR = solvec(10);
    if solvec(10)>0 && solvec(11)==0
        rchain = solp2smlp(solvec(10));%生成直链，可以把这部分模块化
       naph_t = insertBefore(naph_t,1,rchain); 
    elseif solvec(10)>0 && solvec(11)>0
        rchain=soli2smli(solvec(10),solvec(11));
        naph_t = insertBefore(naph_t,1,rchain);
    end
    nme = solvec(12); % 环上甲基数量
    if nme>0 % 先判断换上甲基的位置
        for i = 1:nme
            mchain = insertAfter(naph_t,2+(i-1).*4,'c');% ??
            naph_t = mchain;
        end
        if solvec(11)>0
           ccarb = solvec(10)-nme;% 去掉环上的甲基
           isop = soli2smi(ccarb,solvec(11));
           naph_t = insertBefore(naph_t,1,isop);
        end
    end
else
    % 烯烃
    % 在饱和烃SML的基础上增加双键
    mch = solismi(carb,solvec(11)); % 构造链烷烃SMILES
    len = length(mch);
    naph_t = insertAfter(mch,len-1,'=');
end
naph = naph_t;
end