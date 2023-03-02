
%% 构造支链

 %% 构造异构烷烃SMILES向量
function isopafin = soli2smli(icarn,brn)
% icarn 小于4 没有异构体
% brn>0 已在入口处判断
    if icarn >= 4 
        mcarb = icarn - brn;
        % 根据brn与（icarn-2）的比较判断仲、叔、季碳的数目
        brme = icarn-2;
        brcyc = floor(brn./brme);% brcyc 最大是2
        brsme = mod(brn,brme);% brsme 小于brme
        if brcyc ==0 
            % 最多为叔碳
            pafin = solp2smlp(mcarb); % 构造主链
            %pafin = insertAfter(pafin,2,'(c)'); % 第一次插入'（c）'
            for i = 1:brn
                pafin = insertAfter(pafin,2+(i-1).*4,'(c)');
            end
            % 甲基数量大于
        elseif brcyc == 1 && brsme == 0
            meunit = 'c(c)';
            pafin = solmc2smc(brme,meunit);
        elseif brcyc==1 && brsme >0 
            me_unit = 'c(c)';
            pafin = solmc2smc(brme,me_unit);
            for i = 1:brsme
                pafin = insertAfter(pafin,5+(i-1).*4,'(c)');
            end
        elseif brcyc == 2 && brsme == 0
            tert_unit = 'c(c)(c)';
            pafin = solmc2smc(brme,tert_unit);
        else
            fprintf('excceding the branch limits!');
            return
        end
    else
        fprintf('the carbon number is less than 4, no matching SMILES!');
        return        
    end
    isopafin = pafin;
    function mainch = solmc2smc(brm,strn)
            %meunit = 'c(c)';
            mainch_a = repmat(strn,brm);% 先构成c(c)....c(c)
            mainch = ['c',mainch_a,'c'];
    end

     %% 构造正构烷烃SMILES向量
    function paraffin = solp2smlp(carn)
        a = 'c';
        paraffin = repmat(a,1,carn);
    end

end