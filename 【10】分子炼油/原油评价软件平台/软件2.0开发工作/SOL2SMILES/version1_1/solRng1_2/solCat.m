%% SOL 2 smiles 
% 对sol向量进行分子类型判断
% Comp为输入SOL向量
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
    hetero=O_+RO+O+RN+NN+AN+RS+S;% 特殊官能团
    paraffin = (hetero+AA+A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&(R~=0)&(H==1); % 链烷烃
    olefin = (hetero+AA+A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&(R~=0)&(H==0);% 脂肪族烯烃
    cyc_pentane = (hetero+AA+A6+A4+A2+N6+N4+N3+N2+N1==0)&(N5~=0)&(H==0);% 环戊烷
    cyc_pentene = (hetero+AA+A6+A4+A2+N6+N4+N3+N2+N1==0)&(N5~=0)&(H<0);% 环戊烯 H == -2?
    cyc_hexane = (hetero+AA+A6+A4+A2+N5+N4+N3+N2+N1==0)&(N6~=0)&(H==0);% 环己烷
    cyc_hexene = (hetero+AA+A6+A4+A2+N6+N4+N3+N2+N1==0)&(N6~=0)&(H<0);% 环己烯 H == -1?
    hyd_indane = (hetero+AA+A6+A4+A2+N5+N4+N2+N1==0)&(N6==1)&(N3~=0);% 氢化茚满
    hyd_chrysane = (hetero+AA+A6+A4+A2+N5+N3+N2+N1==0)&(N6==1)&(N4~=0)&(H==0);% 氢化?类  %phenanthrene 菲
    hyd_chrysene = (hetero+AA+A6+A4+A2+N5+N3+N2+N1==0)&(N6==1)&(N4~=0)&(H<0);
    hyd_pyrene = (hetero+AA+A6+A4+A2+N5+N2+N1==0)&(N6==1)&(N4~=0)&(N3~=0)&(H==0);%氢化芘
    benzene = (hetero+AA+A4+A2+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(H==0);%苯
    benzene_o = (hetero+AA+A4+A2+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(H==-1);%烯烃基苯
    indane = (hetero+AA+A4+A2+N6+N5+N4+N2+N1==0)&(A6==1)&(N3~=0);%茚
    hydr_naphthalene = (hetero+AA+A4+A2+N6+N5+N3+N2+N1==0)&(A6==1)&(N4~=0);%萘的变体
    hydr_pyrene_benz = (hetero+AA+A4+A2+N6+N5+N2+N1==0)&(A6==1)&(N4~=0)&(N3~=0);%氢化芘
    naphthalene = (hetero+AA+A2+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(A4~=0);%萘
    phenanthrene = (hetero+AA+A2+N6+N5+N4+N3+N2==0)&(A6==1)&(A4~=0)&(N1==1);%
    acenaphthene = (hetero+AA+A2+N6+N5+N4+N3+N1==0)&(A6==1)&(A4~=0)&(N2==1);%苊
    pyrene_benzo = (hetero+AA+A2+N6+N5+N4+N2+N1==0)&(A6==1)&(A4~=0)&(N3~=0);%氢化芘
    chrysene_benzo = (hetero+AA+A2+N6+N5+N4+N2+N1==0)&(A6==1)&(A4~=0)&(N4~=0);
    benzopyrene_p = (hetero+AA+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(A4~=0)&(A2~=0);
    diphenylmethane = (hetero+AA+N6+N5+N4+N3+N2==0)&(A6==2)&(N1~=0);%二苯基甲烷
    indene_phylm = (hetero+AA+N6+N5+N4+N2==0)&(A6==2)&(N3~=0)&(N1~=0);%苯甲基茚 23
    naphene_phylm = (hetero+AA+N6+N5+N3+N2==0)&(A6==2)&(N4~=0)&(N1~=0);%苯甲基萘 24
    bicyclohexyl = (hetero+A4+A2+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==0)&(N6~=0);% 联环己烷
    cychexyl_hydnaphene = (hetero+A4+A2+N5+N3+N2+N1==0)&(AA==1)&(A6==0)&(N6~=0)&(N4~=0);% 
    benzcyclohexyl = (hetero+A4+A2+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==1)&(N6~=0);% 
    fluorene_hyd = (hetero+A4+A2+N5+N4+N3+N2==0)&(AA==1)&(A6==1)&(N6~=0)&(N1~=0);%芴
    biIndane = (hetero+A4+A2+N5+N4+N2+N1==0)&(AA==1)&(A6==1)&(N6~=0)&(N3~=0);%
    naphyl_hnaphene = (hetero+A4+A2+N5+N3+N2+N1==0)&(AA==1)&(A6==1)&(N6~=0)&(N4~=0);%
    benzopyrene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==1)&(A4~=0);% 
    biphenyl = (hetero+A4+A2+N6+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==2);% 
    fluorene = (hetero+A4+A2+N6+N5+N4+N3+N2==0)&(AA==1)&(A6==2)&(N1~=0);% 
    bih_phenanthrene = (hetero+A4+A2+N6+N5+N4+N3+N1==0)&(AA==1)&(A6==2)&(N2~=0);%二氢菲
    phyl_hnaphene = (hetero+A4+A2+N6+N5+N3+N2+N1==0)&(AA==1)&(A6==2)&(N4~=0);
    phyl_fluorene = (hetero+A4+A2+N6+N5+N3+N2==0)&(AA==1)&(A6==2)&(N4~=0)&(N1~=0);
    h_chrysene = (hetero+A4+A2+N6+N5+N3+N1==0)&(AA==1)&(A6==2)&(N4~=0)&(N2~=0);
    phyl_naphene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==2)&(A4~=0);% 
    naphyl_naphene = (hetero+A2+N6+N5+N3+N2+N1==0)&(AA==1)&(A6==2)&(A4~=0)&(N4~=0);% 
    phyl_cycheyl_fluorene = (hetero+A2+N6+N5+N3+N2==0)&(AA==1)&(A6==2)&(A4~=0)&(N4~=0)&(N1~=0);% 
    h6_Picene = (hetero+A2+N6+N5+N3+N1==0)&(AA==1)&(A6==2)&(A4~=0)&(N4~=0)&(N2~=0);% 
    fluoranthene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==1);% 荧蒽
    h4_Perylene = (hetero+A2+N6+N5+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==1)&(N4~=0);% 四氢苝
    perylene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==2);%苝
    benzo_4hperylene = (hetero+A2+N6+N5+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==2)&(N4~=0);% 苯并四氢苝
    benzo_perylene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==3);% 苯并四氢苝
    %————————————————————————————————————
    %% 
    % 杂环分子
    
    %% 判断类型，输出smiles
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
    %
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
    
    
    %%
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