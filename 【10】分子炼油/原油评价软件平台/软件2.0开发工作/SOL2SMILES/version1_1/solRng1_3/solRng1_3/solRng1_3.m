% version V 1_3
% date: 2018-01-18
% by chenhui
% 系统判断分子类型
%%
% version V 1_2
% date: 2018-01-15
% by chenhui
% 增加稠环芳烃类型
% 增加苯环取代基
% 修改环烷烃等取代基显示不出分子结构图的bug(smiles格式问题) 2018-1-16
%%
% version V 1_1
% date: 2018-01-12
% by chenhui
% 替换 insertBefore,insertAfter函数
%%
% version V 1_0
% date: 2017-12-23
% by chenhui
% sol 转 smiles
% refernce :RNG.m

%先判断分子类型
%% SOL 2 smiles 
% 对sol向量进行分子类型判断
% Comp为输入SOL向量
function [flag,sml_ts,erro] = solRng1_3(Comp,SOLCN,SOLHN)

sml_ts = 'NaN';
flag = 0;
erro = 0;
% step 1 求总碳数
carbon_t = sum(Comp.*SOLCN); % the number of carbon atoms
hydron_t = sum(Comp.*SOLHN); % the number of hydrongen atom
    A6=Comp(1); % 提取各结构单元
    A4=Comp(2);
    A2=Comp(3);
    N6=Comp(4);N5=Comp(5);N4=Comp(6);
    N3=Comp(7);N2=Comp(8);N1=Comp(9);
    R=Comp(10);br=Comp(11);me=Comp(12);
    H=Comp(13);AA=Comp(14);S=Comp(15);
    RS=Comp(16);AN=Comp(17);NN=Comp(18);
    RN=Comp(19);O=Comp(20);RO=Comp(21);
    O_=Comp(22);Ni=Comp(23);V=Comp(24);
    hetero=O_+RO+O+RN+NN+AN+RS+S+V+Ni;% 特殊官能团
    
    %% 
  
    %% 判断类型，输出smiles
    if hetero == 0
        paraffin = (hetero+AA+A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&(R~=0)&(H==1); % 链烷烃
        olefin = (hetero+AA+A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&(R~=0)&(H==0);% 脂肪族烯烃
        cyc_pentane = (hetero+AA+A6+A4+A2+N6+N4+N3+N2+N1==0)&(N5~=0)&(H==0);% 环戊烷
        cyc_pentene = (hetero+AA+A6+A4+A2+N6+N4+N3+N2+N1==0)&(N5~=0)&(H<0);% 环戊烯 H == -2?
        cyc_hexane = (hetero+AA+A6+A4+A2+N5+N4+N3+N2+N1==0)&(N6~=0)&(H==0);% 环己烷
        cyc_hexene = (hetero+AA+A6+A4+A2+N4+N3+N2+N1==0)&(N6~=0)&(H==-1);% 环己烯 H == -1?
        hyd_indane = (hetero+AA+A6+A4+A2+N5+N4+N2+N1==0)&(N6==1)&(N3~=0);% 氢化茚满
        hyd_chrysane = (hetero+AA+A6+A4+A2+N5+N3+N2+N1==0)&(N6==1)&(N4~=0)&(H==0);% 氢化?类  %phenanthrene 菲
        hyd_chrysene = (hetero+AA+A6+A4+A2+N5+N3+N2+N1==0)&(N6==1)&(N4~=0)&(H==-1);
        hyd_pyrene = (hetero+AA+A6+A4+A2+N5+N2+N1==0)&(N6==1)&(N4~=0)&(N3~=0)&(H==0);%氢化芘
        benzene = (hetero+AA+A4+A2+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(H==0);%苯
        benzene_o = (hetero+AA+A4+A2+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(H==-1);%烯烃基苯
        indane = (hetero+AA+A4+A2+N6+N5+N4+N2+N1==0)&(A6==1)&(N3~=0);%茚
        hydr_naphthalene = (hetero+AA+A4+A2+N6+N5+N3+N2+N1==0)&(A6==1)&(N4~=0);%萘的变体
        hydr_pyrene_benz = (hetero+AA+A4+A2+N6+N5+N2+N1==0)&(A6==1)&(N4~=0)&(N3~=0);%氢化芘
        naphthalene = (hetero+AA+A2+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(A4~=0);%萘
        Cyclopenta_phenanthrene = (hetero+AA+A2+N6+N5+N4+N3+N2==0)&(A6==1)&(A4~=0)&(N1==1);%
        acenaphthene = (hetero+AA+A2+N6+N5+N4+N3+N1==0)&(A6==1)&(A4==1)&(N2==1);%苊
        dihydropyrene45 = (hetero+AA+A2+N6+N5+N4+N3+N1==0)&(A6==1)&(A4==2)&(N2==1);%
        pyrene_benzo = (hetero+AA+A2+N6+N5+N4+N2+N1==0)&(A6==1)&(A4==1)&(N3==2);%氢化芘
        chrysene_benzo = (hetero+AA+A2+N6+N5+N2+N1==0)&(A6==1)&(A4~=0)&(N4~=0);
        pyrene = (hetero+AA+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(A4==2)&(A2==1);
        benzo_a_pyrene = (hetero+AA+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(A4==3)&(A2==1);
        diphenylmethane = (hetero+AA+N6+N5+N4+N3+N2==0)&(A6==2)&(N1~=0);%二苯基甲烷
        indene_phylm = (hetero+AA+N6+N5+N4+N2==0)&(A6==2)&(N3~=0)&(N1~=0);%苯甲基茚 23
        naphene_phylm = (hetero+AA+N6+N5+N3+N2==0)&(A6==2)&(N4~=0)&(N1~=0);%苯甲基萘 24
        bicyclohexyl = (hetero+A4+A2+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==0)&(N6==2);% 联环己烷
        cychexyl_hydnaphene = (hetero+A4+A2+N5+N3+N2+N1==0)&(AA==1)&(A6==0)&(N6~=0)&(N4~=0);% 
        benzcyclohexyl = (hetero+A4+A2+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==1)&(N6~=0);% 
        fluorene_hyd = (hetero+A4+A2+N5+N4+N3+N2==0)&(AA==1)&(A6==1)&(N6==1)&(N1~=0);%芴
        biIndane = (hetero+A4+A2+N5+N4+N2+N1==0)&(AA==1)&(A6==1)&(N6~=0)&(N3~=0);%
        naphyl_hnaphene = (hetero+A4+A2+N5+N3+N2+N1==0)&(AA==1)&(A6==1)&(N6~=0)&(N4~=0);%
        benzofluoranthene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==1)&(A4==3);% 苯并荧蒽
        benzoperylene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==1)&(A4==4);% 苯并苝

        biphenyl = (hetero+A4+A2+N6+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==2);% 
        fluorene = (hetero+A4+A2+N6+N5+N4+N3+N2==0)&(AA==1)&(A6==2)&(N1~=0);% 
        bih_phenanthrene = (hetero+A4+A2+N6+N5+N4+N3+N1==0)&(AA==1)&(A6==2)&(N2~=0);%二氢菲
        biphynaphene = (hetero+A4+A2+N6+N5+N3+N2+N1==0)&(AA==1)&(A6==2)&(N4==2);
        phyl_4hnaphene = (hetero+A4+A2+N6+N5+N3+N2+N1==0)&(AA==1)&(A6==2)&(N4==1);
        phyl_fluorene = (hetero+A4+A2+N6+N5+N3+N2==0)&(AA==1)&(A6==2)&(N4~=0)&(N1~=0);
        h_chrysene = (hetero+A4+A2+N6+N5+N3+N1==0)&(AA==1)&(A6==2)&(N4~=0)&(N2~=0);
        phyl_naphene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==2)&(A4~=0);% 
        naphyl_naphene = (hetero+A2+N6+N5+N3+N2+N1==0)&(AA==1)&(A6==2)&(A4~=0)&(N4~=0);% 
        phyl_cycheyl_fluorene = (hetero+A2+N6+N5+N3+N2==0)&(AA==1)&(A6==2)&(A4~=0)&(N4~=0)&(N1~=0);% 
        h6_Picene = (hetero+A2+N6+N5+N3+N1==0)&(AA==1)&(A6==2)&(A4~=0)&(N4~=0)&(N2~=0);% 
        fluoranthene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==1);% 荧蒽
        h4_Perylene = (hetero+A2+N6+N5+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==1)&(N4==1);% 四氢苝
        perylene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==2);%苝
        benzo_4hperylene = (hetero+A2+N6+N5+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==2)&(N4==1);% 苯并四氢苝
        benzo_perylene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==3);% 苯并四氢苝
        %————————————————————————————————————
        if paraffin
            if br>0
                  %sml_ts = soli2smli(R,br); %构造异构烷烃 SMILES
                  sml_ts = isoRecur(R-br,br);
            else
                  %sml_ts = solp2smlp(R); % 构造正构烷烃 SMILES
                  sml_ts = msRecur(R,'C');%msRecur
            end
            return
        end
        % 烯烃
        if olefin
            if br>0
                sml_tc = isoRecur(R-br,br);
                sml_ts = [sml_tc(1:end-1),'=C'];
            else
                sml_tc = msRecur(R-1,'C');%msRecur
                sml_ts = ['C=',sml_tc];
            end
            return
        end
        if cyc_pentane
            core_ptane = 'C1CCCC1';
            if br>0 && me==0 
                sml_tc = subRecur(R-br,br);
                sml_ts = [sml_tc,core_ptane];
            elseif br ==0 && me ==0
                sml_tc = msRecur(R,'C');
                sml_ts = [sml_tc,core_ptane];
            elseif br == 0 && me >0 && me <=4
                sml_tc = msRecur(R-me,'C');% R-me>0
                core_ptanet = msRecur(me,'C(C)');
                core_ptaneS = msRecur(4-me,'C');
                sml_ts = [sml_tc,'C1',core_ptanet,core_ptaneS,'1'];
            else
                sml_tc = subRecur(R-me-br,br);% R-me>0
                core_ptanet = msRecur(me,'C(C)');
                core_ptaneS = msRecur(4-me,'C');
                sml_ts = [sml_tc,'C1',core_ptanet,core_ptaneS,'1'];
            end
            return
        end
        %%
        if cyc_pentene 
            core_ptene = 'C1C=CC=C1'; % H == -2
            if br>0 && me==0 
                sml_tc = subRecur(R-br,br);
                sml_ts = [sml_tc,core_ptene];
            elseif br ==0 && me ==0
                sml_tc = msRecur(R,'C');
                sml_ts = [sml_tc,core_ptene];
            elseif br == 0 && me >0 && me <=4 % 未想到好办法
                sml_tc = msRecur(R-1,'C');% R-me>0
                core_ptenet = 'C1C=C(C)C=C1';
                %core_pteneS = msRecur(3-me,'C');
                sml_ts = [sml_tc,core_ptenet];
            else % 未想到好办法
                sml_tc = subRecur(R-1-br,br);% R-me>0
                %sml_tc = msRecur(R-1,'C');% R-me>0
                core_ptenet = 'C1C=C(C)C=C1';
                %core_pteneS = msRecur(3-me,'C');
                sml_ts = [sml_tc,core_ptenet];
            end
            return
        end
        %%
        if cyc_hexane
            core_cyhexane = 'C1CCCCC1';
            if br>0 && me==0 
                sml_tc = subRecur(R-br,br);
                sml_ts = [sml_tc,core_cyhexane];
            elseif br ==0 && me ==0
                sml_tc = msRecur(R,'C');
                sml_ts = [sml_tc,core_cyhexane];
            elseif br == 0 && me >0 && me <=5
                sml_tc = msRecur(R-me,'C');% R-me>0
                core_cyhexanet = msRecur(me,'C(C)');
                core_cyhexaneS = msRecur(5-me,'C');
                sml_ts = [sml_tc,'C1',core_cyhexanet,core_cyhexaneS,'1'];
            else
                sml_tc = subRecur(R-me-br,br);% R-me>0
                core_cyhexanet = msRecur(me,'C(C)');
                core_cyhexaneS = msRecur(5-me,'C');
                sml_ts = [sml_tc,'C1',core_cyhexanet,core_cyhexaneS,'1'];
            end
            return
        end
        %%
        if cyc_hexene
            core_chextene = 'C1ccCCC1'; % H == -1
            if br>0 && me==0 
                sml_tc = subRecur(R-br,br);
                sml_ts = [sml_tc,core_chextene];
            elseif br ==0 && me ==0
                sml_tc = msRecur(R,'C');
                sml_ts = [sml_tc,core_chextene];
            elseif br == 0 && me >0 && me <=4 % 未想到好办法
                sml_tc = msRecur(R-1,'C');% R-me>0
                core_chextenet = 'C1CC=CC(C)C1';
                %core_pteneS = msRecur(3-me,'C');
                sml_ts = [sml_tc,core_chextenet];
            else % 未想到好办法
                sml_tc = subRecur(R-1-br,br);% R-me>0
                %sml_tc = msRecur(R-1,'C');% R-me>0
                core_chextenet = 'C1CC=CC(C)C1';
                %core_pteneS = msRecur(3-me,'C');
                sml_ts = [sml_tc,core_chextenet];
            end
            return
        end
        %%
        if hyd_indane
           h_indane = 'C1CCC2CCCC2C1'; 
           if R>0
              sml_tc = msRecur(R,'C');
              sml_ts = [sml_tc,h_indane];
           else
               sml_ts = h_indane;
           end
           return
        end
        %%
        if hyd_chrysane
            core_chryL = maRecur(N4);
            core_chryR = upper(core_chryL);
            if R > 0
               if br == 0 && me == 0
                  sml_tc = msRecur(R,'C');
                  sml_ts = [sml_tc,core_chryR]; 
               else
                  sml_tc = subRecur(R-br,br);
                  sml_ts = [sml_tc,core_chryR];  
               end
            else
                sml_ts = core_chryR;
            end
            return
        end
        if hyd_chrysene
            core_chryL = maRecur(N4);
            core_chryR = upper(core_chryL);
            core_chryR(1)='c';
            id = find(core_chryR=='(');
            core_chryR(id+1)='c';
            if R > 0
               if br == 0 && me == 0
                  sml_tc = msRecur(R,'C');
                  sml_ts = [sml_tc,core_chryR]; 
               else
                  sml_tc = subRecur(R-br,br);
                  sml_ts = [sml_tc,core_chryR];  
               end
            else
                sml_ts = core_chryR;
            end
            return
        end
        %%
        if hyd_pyrene
            if N3 == 1
                hyd_pyrene_C = 'C1CC2CCCC3CCCC(C1)C23'; % phenalene
            else
                hyd_pyrene_C = 'C1CC2CCC3CCCC4CCC(C1)C2C34'; % perpyrene
            end
            sml_ts = hyd_pyrene_C;
        end
        %% 苯
        if benzene
            sml_tc = 'c1ccccc1';
            meMax=6;
            if R + me == 0
                sml_ts = sml_tc; % 苯
            elseif me == 0
                %sml_tc = 'c1ccccc1'; % 苯 
                sml_ts = subr(R,br,sml_tc);    
            elseif me < meMax % meMax=6
                   %sml_tc = 'c1c(C)c(C)c(C)c(C)c1C'; 
                   if me <= 3 % 邻位开始 br == 0 R 
                       ar_m = msRecur(me,'c(C)');
                       ar = msRecur(3-me,'c');
                       sml_ar = ['c1c',ar_m,ar,'c1'];
                   elseif me == 4
                       ar_m = msRecur(3,'c(C)');
                       sml_ar = ['c1c',ar_m,'c1C'];
                   elseif me == 5
                       sml_ar = 'c1c(C)c(C)c(C)c(C)c1C';   
                   end
                   sml_ts = subr(R-me,br,sml_ar); 
            else
               %me = 5; % 超出最大值，则认为设置苯环上的甲基为5个
               sml_tc = 'c1c(C)c(C)c(C)c(C)c1C';
               sml_ts = subr(R,br,sml_tc);
               %sml_ts = [br_benz,sml_tc];   
            end
            return
        end
        if benzene_o
            sml_tc = 'c1ccccc1';
            meMax=6;
            if R + me == 0
                sml_ts = sml_tc; % 苯
            elseif me == 0
                %sml_tc = 'c1ccccc1'; % 苯 
                sml_ts = subro(R,br,sml_tc);    
            elseif me < meMax % meMax=6
                   %sml_tc = 'c1c(C)c(C)c(C)c(C)c1C'; 
                   if me <= 3 % 邻位开始 br == 0 R 
                       ar_m = msRecur(me,'c(C)');
                       ar = msRecur(3-me,'c');
                       sml_ar = ['c1c',ar_m,ar,'c1'];
                   elseif me == 4
                       ar_m = msRecur(3,'c(C)');
                       sml_ar = ['c1c',ar_m,'c1C'];
                   elseif me == 5
                       sml_ar = 'c1c(C)c(C)c(C)c(C)c1C';   
                   end
                   sml_ts = subro(R-me,br,sml_ar); 
            else
               %me = 5; % 超出最大值，则认为设置苯环上的甲基为5个
               sml_tc = 'c1c(C)c(C)c(C)c(C)c1C';
               sml_ts = subro(R,br,sml_tc);
               %sml_ts = [br_benz,sml_tc];   
            end
            return
        end
        if indane
            core_DNTT = 'C1Cc2ccccc2C1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if hydr_naphthalene % N4 = 2,3 not yet
            core_DNTT = 'C1CCc2c(C1)cccc2';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if hydr_pyrene_benz
            core_DNTT = 'C1CC2CCc3cccc4CCC(C1)C2c34';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if naphthalene
            core_DNTT = chryRecur(A4);
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if Cyclopenta_phenanthrene
            core_DNTT = 'c1cc2Cc3cccc4ccc(c1)c2c34';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if acenaphthene %苊
            core_DNTT = 'c1cc2cccc3CCc(c1)c23';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if dihydropyrene45 %苊
            core_DNTT = 'c1cc2CCc3cccc4ccc(c1)c2c34';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if pyrene_benzo %
            core_DNTT = 'c1cc3CCCc4ccc2CCCc1c2c34';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if chrysene_benzo %
            core_DNTT = 'C1CCc2c(C1)ccc3c2ccc4c3cccc4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if pyrene %
            core_DNTT = 'c1cc2ccc3cccc4ccc(c1)c2c34';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzo_a_pyrene
            core_DNTT = 'c1ccc2c(c1)cc3ccc4cccc5ccc2c3c45';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if diphenylmethane
            core_DNTT = 'c2ccc(Cc1ccccc1)cc2';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if indene_phylm
            core_DNTT = 'c3ccc(Cc2ccc1CCCc1c2)cc3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if naphene_phylm
            core_DNTT = 'c3ccc(Cc2ccc1CCCCc1c2)cc3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if bicyclohexyl
            core_DNTT = 'C2CCC(C1CCCCC1)CC2';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if cychexyl_hydnaphene
            core_DNTT = 'C3CCC(C2CCCC1CCCCC12)CC3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzcyclohexyl
            core_DNTT = 'C1CCC(c2ccccc2)CC1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if fluorene_hyd
            core_DNTT = 'C1CCC3C(C1)c2ccccc2C3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if biIndane
            core_DNTT = 'c4cc1CCCc1c(C3CCCC2CCCC23)c4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if naphyl_hnaphene
            core_DNTT = 'C1CCC2C(C1)CCCC2c3cccc4CCCCc34';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzofluoranthene
            core_DNTT = 'C1=CC2=C3C(=C1)C4=CC=CC5=C4C3=C(C=C2)C=C5';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzoperylene
            core_DNTT = 'c1cc2ccc3ccc4ccc5cccc6c5c4c3c2c6c1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if biphenyl
            core_DNTT = 'c1ccc(c2ccccc2)cc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if fluorene
            core_DNTT = 'c1ccc3c(c1)Cc2ccccc23';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if bih_phenanthrene
            core_DNTT = 'c1ccc2c(c1)c3ccccc3CC2';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if biphynaphene
            core_DNTT = 'C1CCc2c(C1)cccc2c3cccc4CCCCc34';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if phyl_4hnaphene
            core_DNTT = 'c1cccc(c1)c2cccc3CCCCc23';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if phyl_fluorene
            core_DNTT = 'C1CCc2ccc3Cc4ccccc4c3c2C1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if h_chrysene
            core_DNTT = 'c1ccc2c(c1)CCc3c2ccc4CCCCc43';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if phyl_naphene
            core_DNTT = 'c1cccc(c1)c2cccc3ccccc23';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if naphyl_naphene
            core_DNTT = 'C1CCc2c(C1)cccc2c3cccc4ccccc34';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if phyl_cycheyl_fluorene
            core_DNTT = 'C1CCc2c3Cc4ccc5ccccc5c4c3ccc2';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if h6_Picene
            core_DNTT = 'C1CCc2ccc3c4ccc5ccccc5c4ccc3c2C1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if fluoranthene
            core_DNTT = 'c1ccc-2c(c1)-c3cccc4c3c2ccc4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if h4_Perylene
            core_DNTT = 'C1CC3c2c(C1)cccc2c5c4c3cccc4ccc5';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if perylene
            core_DNTT = 'c1cc3c2c(c1)cccc2c5c4c3cccc4ccc5';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzo_4hperylene
            core_DNTT = 'C1Cc2c6ccccc6cc3c2C(C1)c4cccc5cccc3c45';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzo_perylene
            core_DNTT = 'c1cc2c6ccccc6cc3c2c(c1)c4cccc5cccc3c45';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t)]; 
        flag = 1;
%%  
    elseif (hetero-RS == 0)&&(RS==1)
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'S'];
        flag = 2;
    elseif (hetero-S == 0)&&(S==2)
        % 杂环分子 2S
        DNTT = (hetero-S == 0)&(S==2)&(A2+N6+N5+N4+N2==0)&(AA==1)&(A6==2)&(A4==2)&(N3==1)&(N1==1)&(H==-1); %
        DNTT_4H = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==1)&(N4==1)&(N3==1)&(N1==1)&(H==-1); %
        DNTT_6H = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==1)&(N4==1)&(N3==1)&(N1==1)&(H==0); %
        DNTT_A4 = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==1)&(N4==0)&(N3==1)&(N1==1)&(H==-1); %
        biCychexthieno = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==0)&(N4==2)&(N3==2)&(N1==0)&(H==-2); %
        DNTT_2N4_2H = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==0)&(N4==2)&(N3==1)&(N1==1)&(H==0); %
        DNTT_2N4 = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==0)&(N4==2)&(N3==1)&(N1==1)&(H==-1); %
        cyc1_thieno = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==0)&(N4==1)&(N3==2)&(N1==0)&(H==-2); %
        DNTT_1N4_2H = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==0)&(N4==1)&(N3==1)&(N1==1)&(H==0); %
        DNTT_1N4 = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==0)&(N4==1)&(N3==1)&(N1==1)&(H==-1); %
        bithiophene = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==0)&(N4==0)&(N3==2)&(N1==0)&(H==-2); %
        benzo2_thiophene = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==0)&(N4==0)&(N3==1)&(N1==1)&(H==-1); %
        benzothieno_2H = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==0)&(N4==0)&(N3==1)&(N1==1)&(H==0); %
        DNTT_N6N4 = (hetero-S == 0)&(S==2)&(A2+N5+N2==0)&(AA==1)&(A6==1)&(A4==1)&(N6==1)&(N4==1)&(N3==1)&(N1==1)&(H==0); %
        DNTT_2N4N6 = (hetero-S == 0)&(S==2)&(A2+N5+N2==0)&(AA==1)&(A6==1)&(A4==0)&(N6==1)&(N4==2)&(N3==1)&(N1==1)&(H==0); %
        DNTT_0A4N4 = (hetero-S == 0)&(S==2)&(A2+N5+N2==0)&(AA==1)&(A6==1)&(A4==0)&(N6==1)&(N4==1)&(N3==1)&(N1==1)&(H==0); %
        benzo2_thiopheneH = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==1)&(A4==0)&(N4==0)&(N3==1)&(N1==1)&(H==0); %

        DNTT_perH = (hetero-S == 0)&(S==2)&(A2+N5+N2==0)&(AA==1)&(A6==0)&(A4==0)&(N6==2)&(N4==2)&(N3==1)&(N1==1)&(H==0); %
        DNTT_prtN4 = (hetero-S == 0)&(S==2)&(A2+N5+N2==0)&(AA==1)&(A6==0)&(A4==0)&(N6==2)&(N4==1)&(N3==1)&(N1==1)&(H==0); %
        prtH_Benzo2thieno = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==1)&(A6==0)&(A4==0)&(N6==2)&(N4==0)&(N3==1)&(N1==1)&(H==0); %
        cyhexS_indan = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==0)&(A6==1)&(A4==0)&(N6==0)&(N4==1)&(N3==2)&(N1==0)&(H==-2); %
        thieno_indan = (hetero-S == 0)&(S==2)&(A2+N6+N5+N2==0)&(AA==0)&(A6==1)&(A4==0)&(N6==0)&(N4==0)&(N3==2)&(N1==0)&(H==-2); % H == 0 也有可能
        if DNTT
            core_DNTT = 'c1ccc2c(c1)ccc3c2C4=C(S3)c5c6ccccc6ccc5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_4H
            core_DNTT = 'C1CCc2c(C1)ccc3c2C4=C(S3)c5c6ccccc6ccc5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_6H
            core_DNTT = 'C1CCc2c(C1)ccc3c2C4C(S3)c5c6ccccc6ccc5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_A4
            core_DNTT = 'c1ccc2c(c1)ccc3c2c4c(S3)c5ccccc5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if biCychexthieno  
            core_DNTT = 'c3c1CCSc1c2CCCCc2c3c5cc4CCSc4c6CCCCc56'; % 缺smiles
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_2N4_2H
            core_DNTT = 'C1CCc2c(C1)ccc3c2C4C(S3)c5c6CCCCc6ccc5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_2N4
            core_DNTT = 'C1CCc2c(C1)ccc3c2c4c(S3)c5c6CCCCc6ccc5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if cyc1_thieno
            core_DNTT = 'c2cc1SCCc1cc2c4cc3CCSc3c5CCCCc45';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_1N4_2H
            core_DNTT = 'C1CCc2c(C1)ccc3c2C4C(S3)c5ccccc5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_1N4
            core_DNTT = 'C1CCc2c(C1)ccc3c2c4c(S3)c5ccccc5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if bithiophene
            core_DNTT = 'c2cc1SCCc1cc2c4ccc3SCCc3c4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzo2_thiophene
            core_DNTT = 'c1ccc2c(c1)c3c(S2)c4ccccc4S3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzothieno_2H
            core_DNTT = 'c1ccc2c(c1)C3C(S2)c4ccccc4S3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_N6N4
            core_DNTT = 'c1ccc2c(c1)ccc3c2C4C(S3)C5C6CCCCC6CCC5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_2N4N6
            core_DNTT = 'C1CCc2c(C1)ccc3c2C4C(S3)C5C6CCCCC6CCC5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_0A4N4
            core_DNTT = 'C1CCc2c(C1)ccc3c2C4C(S3)C5CCCCC5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzo2_thiopheneH
            core_DNTT = 'c1ccc2c(c1)C3C(S2)C4CCCCC4S3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_perH
            core_DNTT = 'C1CCC2C(C1)CCC3C2C4C(S3)C5C6CCCCC6CCC5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if DNTT_prtN4
            core_DNTT = 'C1CCC2C(C1)CCC3C2C4C(S3)C5CCCCC5S4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if prtH_Benzo2thieno
            core_DNTT = 'C1CCC2C(C1)C3C(S2)C4CCCCC4S3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if cyhexS_indan
            core_DNTT = 'C1=Cc3c(S1)c2CCCCc2c4c3C=CS4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if thieno_indan
            core_DNTT = 'C1=Cc2c(S1)ccc3c2C=CS3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'S',num2str(S)]; 
        flag = 2;
    elseif (hetero-S == 0)&&(S==1)
        % 1s
        % S == 1
        Perylo_thiophene = (hetero-S == 0)&(S==1)&(A2+N6+N5+N2==0)&(AA==2)&(A6==2)&(A4==2)&(N6==0)&(N4==0)&(N3==0)&(N1==1)&(H==0);
        benzo4_thiophene = (hetero-S == 0)&(S==1)&(A2+N6+N5+N2==0)&(AA==1)&(A6==2)&(A4==2)&(N6==0)&(N4==0)&(N3==0)&(N1==1)&(H==0); % A4 == 0 时为二苯并噻吩，未加入
        benzo2_cyhex_thiophene = (hetero-S == 0)&(S==1)&(A2+N5+N2==0)&(AA==1)&(A6==1)&(A4==1)&(N6==1)&(N4==0)&(N3==0)&(N1==1)&(H==0);
        benzo_cyhex_thiophene = (hetero-S == 0)&(S==1)&(A2+N5+N2==0)&(AA==1)&(A6==1)&(A4==1)&(N6==1)&(N4==0)&(N3==0)&(N1==1)&(H==0);
        cyhex2_thiophene = (hetero-S == 0)&(S==1)&(A6+A4+A2+N5+N2==0)&(AA==1)&(N6==2)&(N4==0)&(N3==0)&(N1==1)&(H==0);
        indan_Thiophene = (hetero-S == 0)&(S==1)&(A4+A2+N6+N5+N2==0)&(AA==0)&(A6==1)&(N4==0)&(N3==2)&(N1==0)&(H==-1);
        benzo_Thiophene = (hetero-S == 0)&(S==1)&(A4+A2+N6+N5+N2==0)&(AA==0)&(A6==1)&(N4==0)&(N3==1)&(N1==0)&(H==-1);
        benzo_Thiophene_2H = (hetero-S == 0)&(S==1)&(A4+A2+N6+N5+N2==0)&(AA==0)&(A6==1)&(N4==0)&(N3==1)&(N1==0)&(H==0);
        fei_Thiophene = (hetero-S == 0)&(S==1)&(A2+N6+N5+N4+N2==0)&(AA==0)&(A6==1)&(A4==2)&(N3==0)&(N1==1)&(H==0);
        benzo_A4_Thiophene = (hetero-S == 0)&(S==1)&(A2+N6+N5+N4+N2==0)&(AA==0)&(A6==1)&(A4==1)&(N3==1)&(N1==0)&(H==0);  % H == -1 
        cyhexThiophene = (hetero-S == 0)&(S==1)&(A6+A4+A2+N5+N2==0)&(AA==0)&(N6==1)&(N4==0)&(N3==1)&(N1==0)&(H==-2);  % H == 0
        perhbenzoThiophene = (hetero-S == 0)&(S==1)&(A6+A4+A2+N5+N2==0)&(AA==0)&(N6==1)&(N4==0)&(N3==1)&(N1==0)&(H==0);  % H == 0
        cyhex_Thiophene = (hetero-S == 0)&(S==1)&(A6+A4+A2+N5+N4+N2==0)&(AA==0)&(N6==1)&(N4==0)&(N3==1)&(N1==0)&(H==0);  % H == 0
        thiophene = (hetero-S == 0)&(S==1)&(A6+A4+A2+N6+N4+N2==0)&(AA==0)&(N5==1)&(N4==0)&(N3==0)&(N1==0)&(H==-2);  % 
        %thiophene_4H = (hetero-S == 0)&(S==1)&(A6+A4+A2+N6+N4+N2==0)&(AA==0)&(N5==1)&(N4==0)&(N3==0)&(N1==0)&(H==0);  % 四氢噻吩
        H4_Thiophene = (hetero-S == 0)&(S==1)&(A6+A4+A2+N6+N4+N2==0)&(AA==0)&(N5==1)&(N4==0)&(N3==0)&(N1==0)&(H==0);  %  四氢噻吩
        thio = (hetero-S == 0)&(S==1)&(A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&(R~=0)&(H==1);
        if Perylo_thiophene
            core_DNTT = 'c1cc2ccc3c4c2c(c1)c6c5c4c(S3)ccc5ccc6';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzo4_thiophene
            core_DNTT = 'c1ccc2c(c1)ccc3c2c4ccc5ccccc5c4S3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzo2_cyhex_thiophene
            core_DNTT = 'c1ccc2c(c1)ccc3c2C4CCCCC4S3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzo_cyhex_thiophene
            core_DNTT = 'c1cc2C3CCCCC3Sc2cc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if cyhex2_thiophene
            core_DNTT = 'C1CC2C3CCCCC3SC2CC1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if indan_Thiophene
            core_DNTT = 'c1cc2C=CSc2c3CCCc13';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzo_Thiophene
            core_DNTT = 'c1cc2C=CSc2cc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzo_Thiophene_2H
            core_DNTT = 'c1cc2CCSc2cc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if fei_Thiophene
            core_DNTT = 'c1cc2c3c(c1)ccc4c3c(S2)ccc4';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzo_A4_Thiophene
            core_DNTT = 'c1cc2c3CCSc3ccc2cc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if cyhexThiophene
            core_DNTT = 'C1Cc2ccSc2CC1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if perhbenzoThiophene
            core_DNTT = 'C1CC2CCSC2CC1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        %cyhex_Thiophene
        if cyhex_Thiophene
            core_DNTT = 'C1CC2CCSC2CC1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if thiophene
            core_DNTT = 'c1ccSc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if H4_Thiophene
            core_DNTT = 'C1CCSC1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if thio
            %%core_DNTT = 'C1CCSC1';
            if br == 0
                sm_tc = msRecur(R-2,'C');
                sml_ts = ['CS',sm_tc];
            else
                sm_tc = isoRecur(R-br,br);
                sml_ts =[sm_tc(1),'S',sm_tc(3:end)];
            end    
            return
        end
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'S']; 
        flag = 3;
    elseif (hetero-AN == 0)&&(AN==1)
    %%
        % AN == 1
        
        Azafluorene_2 =  (hetero-AN == 0)&(AN==1)&(A4+A2+N6+N5+N4+N3+N2+H==0)&(AA==1)&(A6==2)&(N1==1);
        Azapyrene = (hetero-AN == 0)&(AN==1)&(N6+N5+N4+N3+N2+N1+H==0)&(AA==0)&(A6==1)&(A4==2)&(A2==1); % A4 =1,2,3,4, A2 = 0,1 未补充
        AzaNaphthalene = (hetero-AN == 0)&(AN==1)&(N6+N5+N4+N3+N2+N1+H==0)&(AA==0)&(A6==1)&(A4==1)&(A2==0); % A4 =1,2,3,4 萘系类未补充
        AzaNaphthalene_4H = (hetero-AN == 0)&(AN==1)&(A4+A2+N6+N5+N3+N2+N1+H==0)&(AA==0)&(A6==1)&(N4==1)&(A2==0);
        pyridine = (hetero-AN == 0)&(AN==1)&(A4+A2+N6+N5+N3+N2+N1+H==0)&(AA==0)&(A6==1)&(N4==0)&(A2==0); % 吡啶
         if Azafluorene_2
            core_DNTT = 'c1cc2c3cnccc3Cc2cc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if Azapyrene
            core_DNTT = 'c1cc2ccc3ccnc4ccc(c1)c2c34';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if AzaNaphthalene
            core_DNTT = 'c1c2cnccc2ccc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end

        if AzaNaphthalene_4H
            core_DNTT = 'C1CCc2c(C1)cncc2';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if pyridine
            core_DNTT = 'c1cnccc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'N']; 
        flag = 4;
    elseif (hetero-NN == 0)&&(NN==1)
       %%
        % NN=1
        Dibenzocarbazole = (hetero-NN == 0)&(NN==1)&(A2+N6+N5+N4+N3+N2+H==0)&(AA==1)&(A6==2)&(A4==2)&(N1==1); % 
        carbazole = (hetero-NN == 0)&(NN==1)&(A2+N6+N5+N4+N3+N2+H==0)&(AA==1)&(A6==2)&(A4==0)&(N1==1); % 
        benzocarbazole = (hetero-NN == 0)&(NN==1)&(A2+N6+N5+N4+N3+N2+H==0)&(AA==1)&(A6==2)&(A4==1)&(N1==1); %
        benzocarbazole_6H = (hetero-NN == 0)&(NN==1)&(A2+N5+N4+N3+N2+H==0)&(AA==1)&(A6==1)&(A4==1)&(N6==1)&(N1==1); %
        carbazole_6H = (hetero-NN == 0)&(NN==1)&(A4+A2+N5+N4+N3+N2+H==0)&(AA==1)&(A6==1)&(N6==1)&(N1==1); %
        Pyrrole = (hetero-NN == 0)&(NN==1)&(A6+A4+A2+N5+N4+N3+N2+N1+H==0)&(AA==0)&(N5==1)&(H==-2); %
        Pyridine_diH = (hetero-NN == 0)&(NN==1)&(A6+A4+A2+N5+N4+N3+N2+N1+H==0)&(AA==0)&(N6==1)&(H==-2); %
        
        if Dibenzocarbazole
            core_DNTT = 'c1ccc2c(c1)ccc3c2c4ccc5ccccc5c4N3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if carbazole
            core_DNTT = 'c1cc2c3ccccc3Nc2cc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzocarbazole
            core_DNTT = 'c1ccc2c(c1)ccc3c2c4ccccc4N3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if benzocarbazole_6H
            core_DNTT = 'c1ccc2c(c1)ccc3c2C4CCCCC4N3';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if carbazole_6H
            core_DNTT = 'c1cc2C3CCCCC3Nc2cc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if Pyrrole
            core_DNTT = 'c1ccNc1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        if Pyridine_diH
            core_DNTT = 'c1cNccC1';
            if R == 0
                sml_ts = core_DNTT ;
            else
                if br == 0 && me == 0
                    sm_tc = msRecur(R,'C');
                    sml_ts = [sm_tc,core_DNTT];
                elseif br~=0 && me == 0
                    sml_br = subRecur(R-br,br);
                    sml_ts = [sml_br,core_DNTT] ;
                elseif br==0 && me ~= 0 
                    sml_ts = core_DNTT ;
                elseif br~=0 && me ~= 0
                    sml_ts = core_DNTT ;
                end
            end
            return
        end
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'N']; 
        flag = 5;
    elseif (O_~=0) && (hetero-O_==0)
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'O'];
        flag = 7;
    elseif (RN~=0) && (hetero-RN==0)   
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'N'];
        flag = 6;
    elseif (RO~=0) && (hetero-RO==0)   
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'O'];
        flag = 8;
    elseif (O~=0) && (hetero-O==0)   
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'O'];
        flag = 9;
    elseif (RO~=0) && (O_~=0) &&(hetero-RO-O_==0) 
        phenanthrene_acetate = (A2+N6+N5+N3+N2+N1==0)&(AA==0)&(A6==2)&(A4==1)&(N4==1)&(R>=2);
        p_acetate = (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&(AA==0)&(R>=2)&(H==1);
        if phenanthrene_acetate
            sml_ts = 'OC(=O)C1CC(C)Cc2ccc3ccccc3c12';
            return
        end
        if p_acetate 
            if br==0
                sml_tc = msRecur(R-1,'C');
                sml_ts = ['OC(=O)',sml_tc];
            else
                sml_tc = isoRecur(R-br,br);
                sml_ts = [sml_tc(1:end-1),'C(=O)O'];
            end
            return
        end
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'O',num2str(RO+O_)];
        flag = 10;
        
        
    elseif (S==1) &&(RO==1) && (O_==1) &&(hetero-S-RO-O_==0) 
        sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'S','O',num2str(RO+O_)]; % 
        flag = 11; 
    elseif (NN==4) &&(V==1) && (O_==1) &&(hetero-NN-V-O_==0) % 初氧卟啉钒
        %sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'N',num2str(NN),'V','O']; % 
        sml_ts = 'c1cc2cc5ccc(cc4ccc(cc3ccc(cc1n2)[nH]3)n4)[nH]5';
        flag = 12; 
    elseif (NN==4) &&(Ni==1)&&(hetero-NN-Ni==0) % 卟啉镍
        %sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'N',num2str(NN),'Ni']; % 
        sml_ts = 'c1cc2cc5ccc(cc4ccc(cc3ccc(cc1n2)[nH]3)n4)[nH]5';
        flag = 13;
    end
    
    %% 内置函数 
    
    
    %% 递归法构造异构烷烃SMILES
    function isopafin = isoRecur(iR,brc)
        if brc == 1
            smlp = msRecur(iR-1,'C');
            isopafin = [smlp,'(C)C'];  
        elseif (iR-2)>=brc % 不算端头的甲基碳，只有Rc-2个仲碳，若仲碳大于brc,则brc个仲碳可以变为叔碳，剩余Rc-brc-1为仲碳,最后一个还是伯碳
            smlc = msRecur(brc,'C(C)');
            smlp = msRecur(iR-1-brc,'C');
            isopafin = ['C',smlc,smlp];
        else
            Rt = iR + brc;
            if brc>fix((2*Rt-4)/3)
                brc=fix((2*Rt-4)/3); % Rc-2 仲碳小于brc，则有brc-(Rc-2)个仲碳需变为季碳
            end
            mscd = msRecur(2*brc-Rt+2,'C(C)(C)');
            fbrc = brc - 2*(brc-(Rt-brc-2));
                if fbrc > 0
                    smlc = msRecur(fbrc,'C(C)');
                else
                    smlc = [];
                end
            smlp = msRecur(1,'C'); 
            isopafin = [smlp,mscd,smlc,smlp];  
        end
    end
    %% 构造取代基
% 递归算法构造带支链的取代基
% Rc = R - br 剩余碳
    function sub = subRecur(Rc,brc)
        if brc == 1
            smlp = msRecur(Rc,'C');
            sub = [smlp,'(C)'];  
        elseif (Rc-1)>brc % 不算端头的甲基碳，只有Rc-1个仲碳，若仲碳大于brc,则brc个仲碳可以变为叔碳，剩余Rc-brc-1为仲碳,最后一个还是伯碳
            smlc = msRecur(brc,'C(C)');
            smlp = msRecur(Rc-brc,'C');
            sub = [smlp,smlc];
        else % Rc-1 仲碳小于brc，则有brc-(Rc-1)个仲碳需变为季碳
            mscd = msRecur(brc-(Rc-1),'C(C)(C)');
            fbrc = brc - 2*(brc-(Rc-1));
            if fbrc > 0
                smlc = msRecur(fbrc,'C(C)');
            else
                smlc = [];
            end
            smlp = msRecur(1,'C'); 
            sub = [smlp,smlc,mscd];  
        end

    end
    function ms = msRecur(R,carbon) % carbon 类型 char
        if R ==0
            ms = [];
        elseif R ==1
            ms = carbon;
        else
            ms = [msRecur(R-1,carbon),carbon];
        end
         %return
    end
%% 递归算法构造萘、菲、?、苉
    function multAr = maRecur(nf)
        %multArT = ;
        if nf == 1
            multAr = 'c1ccc2c(c1)cccc2';
        else
            multArt = maRecur(nf-1);
            multArS = [multArt(1:end-2),num2str(nf+1),multArt(end-1:end)];
            addstr = ['cccc',num2str(nf+1)];
            multAr = [multArS,addstr];
        end
    end
    %% 构造苯环上的取代基
    function brsub = subro(Rc,brc,bchar)
        if brc == 0 || Rc <= 2
            mrpfin = msRecur(Rc,'C'); % 取代基上无支链
            % mrpfin = msRecur(R); % 递归法构造正构取代基
            brsub = [mrpfin(1),'=',mrpfin(2:end),bchar];
        else % 异构取代基
            if Rc - brc >= 2 % R == 3, br == 1 异丙基
               mrpfin = subRecur(Rc-brc,brc); 
    %                 mrpfin = solp2smlp(R-br); % 构造取代基主链
    %                 mriso = sol2iso(R,br);  % 插入支链
             brsub = [mrpfin(1),'=',mrpfin(2:end),bchar];
            else 
                brc = fix((2*Rc-2)/3); % 若br = 0？R= 1 or R = 2
                mrpfin = subRecur(Rc-brc,brc);  % 按照br-1来构造
                brsub = [mrpfin(1),'=',mrpfin(2:end),bchar];
            end
        end
    end
function brsub = subr(Rc,brc,bchar) % 带双键取代基
        if brc == 0 || Rc <= 2
            mrpfin = msRecur(Rc,'C'); % 取代基上无支链
            % mrpfin = msRecur(R); % 递归法构造正构取代基
            brsub = [mrpfin,bchar];
        else % 异构取代基
            if Rc - brc >= 2 % R == 3, br == 1 异丙基
               sml_ts = subRecur(Rc-brc,brc); 
    %                 mrpfin = solp2smlp(R-br); % 构造取代基主链
    %                 mriso = sol2iso(R,br);  % 插入支链
             brsub = [sml_ts,bchar];
            else 
                brc = fix((2*Rc-2)/3); % 若br = 0？R= 1 or R = 2
                sml_ts = subRecur(Rc-brc,brc);  % 按照br-1来构造
                brsub = [sml_ts,bchar];
            end
        end
end
%% 构造多环芳烃苉等
    function ar_chrye = chryRecur(A4n)
        if A4n == 1
          ar_chrye = 'c1ccc2c(c1)cccc2'; 
        else
            smltc = chryRecur(A4n-1);%num2str(hydron_t)
            ar_chrye = [smltc(1:end-2),num2str(A4n+1),smltc(end-1:end),'cccc',num2str(A4n+1)];
        end
    end
end
