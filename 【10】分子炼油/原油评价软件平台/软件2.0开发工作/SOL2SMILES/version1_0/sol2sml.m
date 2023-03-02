
% version: 1.0
% date : 2017-11-18
% author: chen hui
% description: SOL convert to SMILES
%% 
solvec = zeros(1,24); % sol 向量
solvec(:,10) = 6;
solvec(:,13) = 1;
carbon = sum(solvec.*SOLCN); % the number of carbon atoms
hydron = sum(solvec.*SOLHN); % the number of hydrongen atoms
%tt = mod(hydron,carbon); % 
%ttf = floor(hydron./carbon)

    satom = sum(:,15:24); %判断有无特殊元素，如S、N、O等
    if satom == 0
        hrs = hydron - 2*carbon;
        if hrs == 2  % 判断是否是饱和烃
            brsol = solvec(11);
            rsol = solvec(10); % R单元格的数目就是异构碳总数
            if brsol>0 % 有无支链甲基
                
            else %无直链
                smlp = solp2smlp(carbon);
            end
        end
    end
 %% 构造正构烷烃SMILES向量
function paraffin = solp2smlp(carn)
    a = 'c';
    paraffin = repmat(a,1,carn);
end
%% 构造支链
function mainch = solmc2smc(brm,strn)
            %meunit = 'c(c)';
            mainch_a = repmat(strn,brm);% 先构成c(c)....c(c)
            mainch = ['c',mainch_a,'c'];
end
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
            %pafin = solp2smlp(mcarb); % 构造主链
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
end

