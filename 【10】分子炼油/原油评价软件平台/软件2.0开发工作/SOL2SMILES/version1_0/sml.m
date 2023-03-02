% SOL convert to SMILES
% version 1_0
% by chenhui
% 2017-11-23
%%
% 输入sol向量,从excel中读取
% solvec = zeros(1,24); % sol 向量
% solvec(:,1) = 1;
% solvec(:,4) = 0;
% solvec(:,10) = 6;
% solvec(:,11) = 1;
% solvec(:,12) = 0;
% solvec(:,13) = 0;
function sml_s = sml(solvec,SOLCN,SOLHN)
sml_ts = [];
carbon_t = sum(solvec.*SOLCN); % the number of carbon atoms
hydron_t = sum(solvec.*SOLHN); % the number of hydrongen atoms
% 判断有无特殊元素
satom = sum(solvec(:,15:24)); 
if satom == 0 %判断有无特殊元素，如S、N、O等
    hrs = hydron_t - 2*carbon_t; % 计算氢丰度，为什么先判断特殊元素
    brsol = solvec(11); % 
    rsol = solvec(10); % 总烷基碳数，对于饱和烃，rsol == carbon_t
    if hrs == 2 % 饱和烃
%         brsol = solvec(11); % 
%         rsol = solvec(10); % 总烷基碳数，对于饱和烃，rsol == carbon_t
        if brsol>0
            sml_ts = soli2smli(rsol,brsol); %构造异构烷烃 SMILES
        else
            sml_ts = solp2smlp(rsol); % 构造正构烷烃 SMILES
            % sml_ts = solp2smlp(carbon_t);与上式结果相同
        end
    elseif hrs == 0 % 环烷烃或者是烯烃
        n6sol = solvec(4); % N6
        n5sol = solvec(5); % N5
        if n6sol > 0 || n5sol > 0
            % 环烷烃smiles
            mes = solvec(12);
            if n6sol == 0
                if rsol == 0
                    sml_ts ='C1CCCC1';
                else
                    sml_ts = solna2smna(rsol,brsol,mes,1);
                end
            else
                if rsol == 0
                    sml_ts ='C1CCCCC1';
                else
                    sml_ts = solna2smna(rsol,brsol,mes,0);
                end
            end
        else 
            % 烯烃 smiles
            sml_ts = solo2smlo(rsol,brsol);
        end
    elseif hrs == -2
        n6sol = solvec(4); % N6
        n5sol = solvec(5); % N5
        if n6sol > 0 || n5sol > 0 % 环己烯 环戊烯
            if n6sol == 0
                if rsol == 0
                    sml_ts ='C1CC=CC1';
                else
                    sml_ts = 'CC1CC=CC1';
                end
            else
                if rsol == 0
                    sml_ts ='C1CCC=CC1';
                else
                    sml_ts = 'CC1CCC=CC1';
                end
            end
        else
            % 双烯 smiles
            sml_ts = solso2smlso(rsol,brsol); 
        end
    elseif hrs == -4
        if solvec(5)==1 && solvec(13) == -2
            sml_ts = 'C1C=CC=C1';
        end
    elseif hrs == -6
        %psml = 'c1ccccc1';
        % 构造芳烃
        if solvec(1)==1
        mes = solvec(12);
        sml_ts = solA2smlA(rsol,brsol,mes);
        elseif solvec(5)==1 && solvec(13) == -2
            sml_ts = 'C1C=CC=C1';
        elseif solvec(4)==1 && solvec(13) == -2
            sml_ts = 'C1C=CC=CC1';    
        else
            sml_ts = 'C1CCC2CC3CCCCC3CC2C1';
        end
    elseif hrs == -8 
        if solvec(6)==1
           sml_ts = 'C1CCC2=CC=CC=C2C1'; % 四氢化萘
        else
           sml_ts = 'C1CCC2C(C1)CCC3C2CCC4C3CCCC4';
        end
    elseif hrs == -10
        if solvec(1)==1
            sml_ts = 'C1CCC2=CC3=CC=CCC3CC2C1';
        else
            sml_ts = 'C1=CC=C(C=C1)C2=CC=CC=C2';% 联苯
        end
    elseif hrs ==-12
        if solvec(1)==2
           sml_ts = 'C1=CC=C(C=C1)C2=CC=CC=C2';% 联苯
        elseif solvec(1)==1
           sml_ts = 'C1CCC2C(=CC=C3C2CCC2C3=CCCC2)C1'; % 
        end
    else
        if solvec(1)==2 && solvec(9) ==1
        sml_ts = 'C12=CC=CC=C1C(C=CC=C3)=C3C2';
        elseif solvec(1)==2 && solvec(6) ==1 && solvec(8) ==1
            sml_ts = 'CC1=CC=CC2=C1C=CC3=C2C=CC(=C3)C(C)C';
        elseif solvec(1)==2 && solvec(2) ==1 
            sml_ts = 'C1=CC=C(C=C1)C2=CC=CC3=CC=CC=C32';
        else
            sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t)];
        end
    end
else
    % 判断硫元素
    if solvec(15)>0
       hrs = hydron_t - 2*carbon_t; % 计算氢丰度，为什么先判断特殊元素
       if hrs == 0
           sml_ts = 'S1CCCC1';
       elseif hrs ==-2
           sml_ts ='S1C=CCC1';
       elseif hrs ==-4
           sml_ts ='S1C=CC=C1';
       elseif hrs ==-10 && solvec(1)==1 
           sml_ts ='s2c1ccccc1cc2'; % 苯并噻吩
       elseif hrs == -22 && solvec(1)==2
           sml_ts ='s2c1ccccc1cc2'; % 苯并噻吩
       end
    end
    if solvec(1)==1 && solvec(16)==1
    sml_ts = 'CC(C)C1=CC=C(C=C1)S'; % 4-Isopropylthiophenol
    elseif solvec(4)==1 && solvec(16)==1
        sml_ts = 'SC1CCCCC1';% 环己基硫醇
    elseif solvec(4)==1 && solvec(15)==1
        sml_ts = 'CCC1CCCCS1'; % 
    elseif solvec(5)==1 && solvec(15)==1 && solvec(1)==0
        sml_ts = 'CCC1CCCS1';  % 四氢噻吩  
    elseif solvec(1)==1 && solvec(7) ==1 && solvec(15)==1
        sml_ts = 'C1CSC2=CC=CC=C21';
    elseif solvec(1)==1 && solvec(7) ==1 && solvec(18)==1
        sml_ts = 'C1=CC=C2C(=C1)C=CN2'; % 吲哚
    elseif solvec(1)==1 && solvec(2) ==1 && solvec(17)==1
        sml_ts = 'C1=CC=C2C=NC=CC2=C1';
    elseif solvec(1)==1 && solvec(7) ==1 && solvec(17)==1
        sml_ts = 'C1CCC2=C(C1)C=CC=N2';
    elseif solvec(1)==2 && solvec(9) ==1 && solvec(18)==1
        sml_ts = 'C12=CC=CC=C1C(C=CC=C3)=C3C2';   
    %elseif solvec(1)==1 && solvec(7) ==1 && solvec(15)==1
        
    else
        if solvec(15)>0 || solvec(16)>0
            s = solvec(15)+solvec(16);
            if s >1 
                sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'S',num2str(s)];
            else
                sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'S'];
            end
        elseif solvec(17)>0 || solvec(18)>0 || solvec(19)>0
            N = solvec(17)+solvec(18)+solvec(19);
            if N > 1
                sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'S',num2str(N)];
            else
                sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'N'];
            end
        end
    end
end
sml_s = sml_ts;
%% 构造正构烷烃SMILES
function pfin = solp2smlp(carbon_n)
% if carbon_n == 0 then return 补充非零的判断？？？
    pfin = repmat('C',1,carbon_n);
end

%% 构造异构烷烃SMILES
function isopafin = soli2smli(icarn,brn)
% icarn 小于4 没有异构体
% brn>0 已在入口处判断
    if icarn >= 4 
        mcarb = icarn - brn; % 主链上的烷基碳数
        % 根据brn与（icarn-2）的比较判断仲、叔、季碳的数目
        brme = mcarb-2; % 减去两端甲基
        brcyc = floor(brn./brme);% brcyc 最大是2
        if brcyc>2 % 超出范围
            brn = 2.* brme;
            % 直接构造......
        end
        brsme = mod(brn,brme);% brsme 小于brme
        if brcyc ==0 
            % 最多为叔碳
            pafin = solp2smlp(mcarb); % 构造主链
            for i = 1:brn
                pafin = insertAfter(pafin,2+(i-1).*4,'(C)');
            end
            % 甲基数量大于
        elseif brcyc == 1 && brsme == 0 % 中间全部是叔碳
            meunit = 'C(C)';
            pafin = solmc2smc(brme,meunit);
        elseif brcyc==1 && brsme >0 
            me_unit = 'C(C)';
            pafin = solmc2smc(brme,me_unit);
            for i = 1:brsme
                pafin = insertAfter(pafin,5+(i-1).*4,'(C)');
            end
        elseif brcyc >=2
            tert_unit = 'C(C)(C)';
            pafin = solmc2smc(brme,tert_unit);
%         else
%             fprintf('excceding the branch limits!');
%             return
        end
    else
        pafin = 'C(C)C';       
    end
    isopafin = pafin;
end
%% 构造重复单元
    function mainch = solmc2smc(brm,strn)
            %meunit = 'c(c)';
            mainch_a = repmat(strn,1,brm);% 先构成c(c)....c(c)
            mainch = ['C',mainch_a,'C'];
    end
%% 构造环烷烃SMILES
% sof 0 or 1, 0 N6 ,1 N5
    function naf = solna2smna(R,br,me,sof)
        if sof == 1
           p = 'C1CCCC1' ;
           % 需要判断R br me 的内在关系
           if me > 0
               p = insertBefore(p,1,'C');            
               if br > 0
                   brc = soli2smli(R-me,br);
                   brc_b = ['(',brc,')'];
                   p = insertAfter(p,5,brc_b);
               else 
                   brm = solp2smlp(R-me);
                   brc_m = ['(',brm,')'];
                   p = insertAfter(p,5,brc_m);
               end          
           elseif br > 0
               brc = soli2smli(R,br);
               p = insertBefore(p,1,brc);
           else
               brm = solp2smlp(R);
               p = insertBefore(p,1,brm);
           end
        else   % sof == 0
           p = 'C1CCCCC1' ; 
           if me >0                       
               p = 'CC1CCC(C)C(C)C1'; 
           elseif br > 0
               brc = soli2smli(R,br);
               p = insertBefore(p,1,brc);
           else
               brm = solp2smlp(R);
               p = insertBefore(p,1,brm);
           end
        end
    naf = p;
    end
%% 构造烯烃SMILES
    function olef = solo2smlo(carbon_on,brs)
        if brs > 0
            mc = soli2smli(carbon_on,brs);
            t = length(mc);
            mc(t)=[];
        else
            mc = solp2smlp(carbon_on-1);
            
        end
        olef_t = [mc,'=C'];
        olef = olef_t;
    end
    
   %% 构造芳环
   function aromatic = solA2smlA(rsol,brsol,mes)
       pat = 'c1ccccc1';
       if mes == 0
           if rsol > 0 && brsol > 0
               isobr = soli2smli(rsol,brsol); % 重新改造下，应该从第一个c就能加直链
               isobr_t = ['(',isobr,')'];
               aromatic = insertBefore(pat,1,isobr_t);
           elseif rsol >0 && brsol == 0
               pbr = solp2smlp(rsol);
               aromatic = insertBefore(pat,1,pbr);
           end
       elseif brsol == 0
           pbr = solp2smlp(rsol-mes);
           tr = length(pbr);
           aromatic_t = insertBefore(pat,1,pbr);
           aromatic = insertAfter(aromatic_t,tr+6,'(C)');
       else
           isobr = soli2smli(rsol-mes,brsol);
           isobr_t = ['(',isobr,')'];
           aromatic_t = insertAfter(pat,5,'(C)');
           aromatic = insertBefore(aromatic_t,1,isobr_t);
       end
   end
   
       function sx = solso2smlso(r,b)
       if b > 0 
           pt = soli2smli(r,b);
           pt = insertAfter(pt,length(pt)-1,'=');
           sx = insertAfter(pt,length(pt)-4,'=');
       else
           pt = solp2smlp(r);
           pt = insertAfter(pt,length(pt)-1,'=');
           sx = insertAfter(pt,length(pt)-4,'=');
       end
       end
end