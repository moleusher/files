% version V 1_0
% date: 2017-12-23
% by chenhui
% sol 转 smiles
% refernce :RNG.m

%先判断分子类型

function [flag, sml_ts] = solRng1_0(Comp,SOLCN,SOLHN)
sml_ts = 'NaN';
flag =0; % smiles 结构式为0，分子式为1
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
    hetero=O_+RO+O+RN+NN+AN+RS+S;% 特殊官能团
     acid=(min(O_,RO)~=0);% 酸
     sulfoxide=(min(S,O_)~=0); % 醚类
     % 醇醚
     % 硫醚
     biphenyl=((A6==2)&(AA==1)&(hetero==0)&(N1==0)); % 联苯 (分子式 C12H10)
     %biphenyl/smiles c1ccccc1(c2ccccc2)
     fluorene=((A6>=2)&(AA>=1)&(AA==N1));% 芴\ C12=CC=CC=C1C(C=CC=C3)=C3C2 (分子式 C13H10)
     % 芴\另一种表达式 c12ccccc1c(cccc3)c3c2
     oddsul=((A4>=2)&(N1~=0)&(S~=0)&(AA==0));% 菲基噻吩 c1cc2sc3cccc4ccc(c1)c2c34
     fluoranthene=((A6>=2)&(A4==1)&(AA==2)&(N4==0)&(N3==0));
     % 荧蒽 又名苯并苊 c1ccc-2c(c1)-c3cccc4c3c2ccc4 (分子式 C16H10)
     %fluoranthene=fluoranthene|((A6==1)&(A4>=3)&(AA==1));
     fluoranthene1=(A6==1)&(A4>=3)&(AA==1);%-benzofluoranthene
     % C1=CC2=C3C(=C1)C4=CC=CC5=C4C3=C(C=C2)C=C5 (分子式 C18H10)
     % Benzo[Ghi]Fluoranthene /还有Benzo[k]Fluoranthene等，在荧蒽基础上增加苯环
     por=((N1==4)&(NN==4)&((N5+N3)==4));%porphyrin
     % c1c/2[nH]c(c1)/cc/3\nc(/cc/4\[nH]/c(c\c5n/c(c2)/C=C5)/cc4)C=C3
if hetero==0
   % 无特殊官能团 
   hrs = hydron_t - 2*carbon_t; % 计算氢丰度，为什么先判断特殊元素
   %brsol = solvec(11); % 
   %rsol = solvec(10); % 总烷基碳数，对于饱和烃，rsol == carbon_t
   %% 判断正异构烷烃
   JP = (A6+A4+A2+hetero+N6+N5+N4+N3+N2+N1==0)&(R~=0)&(H==1);%paraffin
   if JP 
      if br>0
          sml_ts = soli2smli(R,br); %构造异构烷烃 SMILES
      else
          sml_ts = solp2smlp(R); % 构造正构烷烃 SMILES
      end
      return % 已经找到smiles结构式，返回主程序
   end
   %% 判断联苯
   biphenyl=((A6==2)&(AA==1)&(N1==0)); % 联苯
   if biphenyl
       sml_tc = 'c1ccccc1(c2ccccc2)'; % biphenyl core smiles
      if R == 0                       % next 增加支链
         sml_ts = sml_tc;
      elseif br == 0 && me== 0  % 长直链
         longbr = solrp(R); % 
         sml_ts = insertAfter(sml_tc,4,longbr);
      elseif br == 0 && me~= 0  % 环取代甲基
         longbr =  solrp(R-1); %
         sml_tc = insertAfter(sml_tc,4,longbr);
         sml_ts = insertAfter(sml_tc,15+R-1,'(C)'); % 目前只能添加一个甲基
      elseif br ~= 0 && me == 0  % 长异构链取代  
         longbr =  solri(R,br); % 
         sml_ts = insertAfter(sml_tc,4,longbr);
      elseif br ~= 0 && me ~= 0  % 长异构链取代  + 环甲基取代
         longbr =  solri(R-1,br); %
         sml_tc = insertAfter(sml_tc,4,longbr);
         index = length(longbr);
         sml_ts = insertAfter(sml_tc,13+index,'(C)'); % 目前只能添加一个甲基
      end
      return
   end
   %% 联环己烷
   bicyhex = (A6+A4+A2==0)&&(N6+N5+N4+N3+N2+N1>=2)&&(AA~=0);
   if bicyhex
      sml_tc = 'C1CCCCC1(C2CCCCC2)';
      if R == 0                       % next 增加支链
         sml_ts = sml_tc;
      elseif br == 0 && me== 0  % 长直链
         longbr = solrp(R); % 
         sml_ts = insertAfter(sml_tc,4,longbr);
      elseif br == 0 && me~= 0  % 环取代甲基
         longbr =  solrp(R-1); %
         sml_tc = insertAfter(sml_tc,4,longbr);
         sml_ts = insertAfter(sml_tc,15+R-1,'(C)'); % 目前只能添加一个甲基
      elseif br ~= 0 && me == 0  % 长异构链取代  
         longbr =  solri(R,br); % 
         sml_ts = insertAfter(sml_tc,4,longbr);
      elseif br ~= 0 && me ~= 0  % 长异构链取代  + 环甲基取代
         longbr =  solri(R-1,br); %
         sml_tc = insertAfter(sml_tc,4,longbr);
         index = length(longbr);
         sml_ts = insertAfter(sml_tc,13+index,'(C)'); % 目前只能添加一个甲基
      end
      return
   end
   
   %% 判断环烷烃
   naph = (A6+A4+A2==0)&(N6+N5+N4+N3+N2+N1~=0)&(H==0);
   % C1CCC2CCCCC2C1 十氢化萘
   if naph 
       % N5 还没有判断0
      if N6 == 0 && N5 == 0
         sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t)]; 
         return
      end
      if N5 ==1 
         sml_ts = 'C1CCCC1'; % 环戊烷
      elseif N6 == 1 && N4 == 0 && N2 ==0 % 环己烷
         cychx = 'C1CCCCC1';
         %sml_ts = addLbr(cychx,R,br,me);
         if R==0 
             sml_ts = cychx;
         elseif br == 0 && me== 0  % 长直链
             longbr = solrp(R);
             sml_ts = insertBefore(cychx,1,longbr);
         elseif br == 0 && me~= 0  % 环取代甲基
             longbr =  solrp(R-1); %
             sml_tc = insertAfter(cychx,4,longbr);
             br_len = length(longbr);
             sml_ts = insertAfter(sml_tc,br_len+6,'(C)'); % 目前只能添加一个甲基
         elseif br ~= 0 && me == 0  % 长异构链取代  
             longbr =  solri(R,br); % 
             sml_ts = insertBefore(cychx,1,longbr);
         elseif br ~= 0 && me ~= 0  % 长异构链取代 + 环甲基取代 
             longbr =  solri(R-1,br); %
             sml_tc = insertBefore(cychx,1,longbr);
             index = length(longbr);
             sml_ts = insertAfter(sml_tc,6+index,'(C)'); % 目前只能添加一个甲基    
         end
      elseif N4~=0 && N2 == 0
             decahydronaphthalene = 'C1CCC2CCCCC2C1' ;
             sml_ts = decahydronaphthalene;
     % c1ccc2c3ccccc3ccc2c1 ()
     %  C1CCC2C(C1)CCC1C3CCCCC3CCC21 (C18H30)
     % Perhydropyrene C2CCC3CCC1C4C(CCC1)CCC2C34 
     % ? chrysene C12=CC=CC=C1C3=C(C(C=CC=C4)=C4C=C3)C=C2 C18H12
      elseif N4~=0 && N2 ~= 0   
             chrysene = 'C12CCCCC1C3C(C(CCC4)C4CC3)CC2';
             sml_ts = chrysene;
      end      
      return    
   end
    %% 环烯烃,在环烷烃的基础上增加双键
    cyalene = (A6+A4+A2+hetero==0)&(N6+N5+N4+N3+N2+N1~=0)&(H<0);
    if cyalene
        % 先构造环烷烃，再增加双键
       if N6~=0 && R==0 && H == -1 && N5==0
           sml_ts = 'C1C=CCCC1';
           % C1C=CC=C1
           % C1=CCCC1
       elseif N6~=0 && R==0 && H <= -2 && N5==0
           sml_ts = 'C1C=CC=CC1';
       elseif N6~=0 && R>=1 && H == -1 && N5==0
           smlp = solp2smlp(R);
           lp = length(smlp);
           smlp1 = insertAfter(smlp,lp,')');
           smlp2 = insertBefore(smlp1,1,'(');
           sml_tc = 'C1=CCCCC1';
           sml_ts = insertAfter(sml_tc,6,smlp2);
       elseif N6~=0 && R>=1 && H <= -2 && N5==0
           smlp = solp2smlp(R);
           sml_tc = 'C1C=CC=CC1'; 
           sml_ts = insertBefore(sml_tc,1,smlp);
       elseif N5~=0 && R==0 && H == -1
           sml_ts = 'C1C=CCC1';  
       elseif N5~=0 && R==0 && H <= -2
           sml_ts = 'C1C=CC=C1';  
       elseif N5~=0 && R>=1 && H == -1
           sml_ts = 'C1C=CCC1';  
       elseif N5~=0 && R>=1 && H <= -2
           sml_ts = 'C1C=CC=C1';      
       end
       return
    end
    %% 烯烃 在链烷烃的基础上增加双键,双烯最多
    alkene = (A6+A4+A2+hetero+N6+N5+N4+N3+N2+N1==0)&(R~=0)&(H<=0);
    if alkene
        if H == 0
            sml_ts = solo2smlo(R,br); % 
        else % 最多两个双键
            sml_ts = solso2smlso(R,br);
        end
        return
    end
    %% 芳烃 芳烃构造类似环烷烃
    a2max =4;
    aromatics = (A2<=a2max)&(A6+A4+A2~=0);
    if aromatics
        % 构造芳烃，多环芳烃
        sml_ts = 'c1ccccc1'; 
        return
    end
    %% 苉
    picene =( A6==1 & A4 ==3 & N4 == 1);
    if picene && (R==0)
        sml_ts = 'C1CCc2C(C1)ccc3c2ccc4c3c2ccc4c3ccc5ccccc54';
%     elseif picene && (R~=0)
%         sml_ts = '苉,增加侧链及甲基' ;
%     else
%         sml_ts = '超出类型苉' ;
    %return
    end
    %% indene 茚
    % A6 = 1 N3 =1 H = -1
    % c1ccc2c(c1)CC=C2
    % C1C=CC2=CC=CC=C21
    indene = (A6==1 & N3==1 & H<=-1);
    if indene
       sml_ts = 'c1ccc2c(c1)CC=C2'; 
       return
    end
    
elseif hetero ==1
    %hetero=O_+RO+O+RN+NN+AN+RS+S;% 特殊官能团
    %% 先判断单个官能团
    %% 1-醚类 甲基叔丁基醚
    ether = (O~=0)&(hetero-O==0); % 醚类
    if ether
        if (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&&(br == 0)&&(H>=1)
            sml_ts = 'CC(C)(C)OC'; %甲基叔丁基醚
        elseif (A6+A4+A2==0)&&(N5>=1)&&(N3+N1==0)&&(H<=-2)
            sml_ts = 'c1ccoc1';% 呋喃
        elseif (A6+A4+A2==0)&&(N5>=1)&&(N3+N1==0)&&(H>-2)
            sml_ts = 'C1CCOC1';% 四氢呋喃
        elseif (A6==1)&&(N5==0)&&(N3+N1~=0)&&(H<=-2)
            sml_ts = 'C1(OC=C2)=C2C=CC=C1'; % 苯并呋喃
            % o2c1ccccc1cc2
        elseif (A6+A4+A2~=0)&&(AA~=0)
            sml_ts = 'o2c1ccccc1c3c2cccc3'; % 二苯并呋喃 Dibenzofuran 
        end
        return
   
    end
    %% 醇
    alcohol = (RO~=0)&(hetero-RO==0); % 醇类
    if alcohol
        if (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&&(br == 0)
            if R == 2
                sml_ts = 'CCO';
            else
                sml_tso = solp2smlp(R); % 构造正构烷烃 SMILES
                sml_ts0 = insertAfter(sml_tso,1,'(');
                sml_ts1 = insertAfter(sml_ts0,3,')');
                sml_ts = insertBefore(sml_tso,1,'O'); % 构造仲醇  
            end
        elseif (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&&(br ~= 0)
            % 构造异构链烷烃醇
            sml_ts = 'CC(C)(C)O';
        elseif (A6+A4+A2==0)&&(N6+N5+N4+N3+N2+N1~=0) 
            % 构造环烷基醇
            sml_ts = 'C1CCC(CC1)O';
        elseif (A6+A4+A2~=0)&&(N6+N5+N4+N3+N2+N1==0)
            % 构造苯酚
            %Phenol  = (A6==1)&&(RO~=0); % Phenol
            sml_ts = 'c1ccc(cc1)O'; % 
            %sml_ts = 'Cc1ccc(O)cc1'; % p-Cresol 对
            %sml_ts = 'Cc1ccccc1O'; % o-Cresol 邻
            %sml_ts = 'Cc1cc(O)ccc1'; % m-Cresol 间
        end
     return  
    end
    %% 3- 酮
    ketone = (O_~=0)&(hetero-O_==0);
    if ketone
        if (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&&(br == 0)
            sml_tc = solp2smlp(R);
            sml_ts = insertAfter(sml_tc,2,'(=O)');% 正构酮
           %sml_ts = 'CC(=O)C ';% (=O)
        elseif (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&&(br ~= 0)
            sml_ts = 'CCC(C)CC(=O)CC'; % 5-METHYL-3-HEPTANONE
        else 
            sml_ts = 'C1CCCCC1=O';% 环己酮
        end
        return
    end
    %% 4- 酸
     %carboxylic_acid = (O_~=0)&(RO~=0)&(hetero-O_-RO==0);

     %% 酯类
     ester = (O_~=0)&(O~=0)&(hetero-O_-O==0);
    if ester
        sml_ts = 'COC(=O)OC';
        %CC(=O)OCC 乙酸乙酯
        return
    end
    %% 5- 硫醚
    %S(CC)CC 二乙硫醚，与CCOCC不同
    % C1CCSC1 四氢噻吩 THT
    % 硫化环戊烷
    thio = (S~=0)&(hetero-S==0); 
    if thio 
        if (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&&(br == 0)&&(H>=1)&&(AA==0)
            if R <3
               sml_ts = 'CSC' ;
            else
               sml_tc = solp2smlp(R-1);
               sml_ts = insertAfter(sml_tc,2,'S');
            end
            %% 7- 噻吩
        elseif  (A6==1)&&(N3>=1)&&(AA==0) % 原来为什么要H<=-2 2017-12-22
               sml_ts = 'c1ccsc1' ; % 噻吩
               if (A6==1)&&(H==-N3)&&(N3>=1) % H == N3
                   sml_ts = 'S1C=CC2=CC=CC=C12' ;% 苯并噻吩
               elseif (A6==1)&&(H==-1)&&(N3>=1)
                   sml_ts = 'C1SC2C=3C(CCC3)C=CC=2C=1' ;% 环戊苯并噻吩
               else
                   sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'S'];
                   flag = 1;
               end
               % 联二苯并噻吩
               % 增加 R
               %return
        
        elseif (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&&(br ~= 0)&&(H>=1)&&(AA==0)
            sml_tc = soli2smli(R-1,br) ; % 构造异构烷烃链
            sml_ts = insertAfter(sml_tc,5,'S'); 
        elseif (A6+A4+A2==0)&&(N6+N5+N4+N3+N2+N1~=0)&&(AA==0)   
            sml_ts = 'C1CCSCC1';
        elseif (A6+A4+A2~=0)&&(N6+N5+N4+N3+N2+N1==0)&&(AA==0)
            sml_ts = 'CSC1=CC=CC=C1';
        elseif (A6+A4+A2~=0)&&(N6+N5+N4+N3+N2+N1~=0)&&(H==0)&&(AA==0)
            sml_ts = 'S2c1ccccc1CC2'; % 需要双键表示吗 2017-12-22
%         elseif (A6+A4+A2~=0)&&(N6+N5+N4+N3+N2+N1~=0)&&(H<=-1)
%             sml_ts = 'S2c1ccccc1CC2'; % 需要双键表示吗 2017-12-22
        elseif AA~=0
           sml_ts = 'c1ccc2c(c1)c3ccccc3s2';% 二苯并噻吩
        end
            return
    end
        
    % C1CCSCC1
    %% 6- 硫醇
    s_ol = (RS~=0) &(hetero-RS==0);
    % 异丙硫醇,2-丙硫醇 CC(S)C or SC(C)C 
    if s_ol
       if (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&&(br == 0)
           % 脂肪族硫醇
           sml_tc = solp2smlp(R);
           sml_ts = insertAfter(sml_tc,2,'(S)');
       elseif (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&&(br ~= 0)
           sml_tc = soli2smli(R,br);
           ollen = length(sml_tc);
           sml_ts = insertAfter(sml_tc,ollen,'S');
       elseif (A6+A4+A2~=0)&&(N6+N5+N4+N3+N2+N1==0)
           sml_ts = 'Sc1cccc(CC)c1';
       elseif (A6+A4+A2==0)&&(N6+N5+N4+N3+N2+N1~=0)   
           sml_ts = 'SC1CCCC(CC)C1';
       end
       return
    end
    
    
    %% 8- 碱性氮 
    % c1ccc2c(c1)c3ccccc3[nH]2 咔唑
    % N1C=CC=C1 吡咯
    pyrol = (N5>=1)&(H<=-2)&(NN>=1);
    if pyrol
      sml_ts = 'N1C=CC=C1';% 吡咯  
      return
    end
    
    indole = (NN~=0)&(hetero-NN==0); % 吲哚类
    if indole
       % (A6==1)&&(H==-N3)&&(N3>=1)
       sml_ts = 'C1(NC=C2)=C2C=CC=C1';% 吲哚
       if (A6>=2)&&(N1>=1)&&(AA>=1)&&(NN>=1)
        sml_ts = 'c1ccc2c(c1)c3ccccc3[nH]2';% 咔唑
        % c1cccc2cc[nH]2c12 不可识别吗？
        % c1(ncc2)c2cccc1 不可识别吗？ 有没有唯一性
       end
       return
    end
    % AN ~=0
    py = (AN~=0)&(hetero-AN==0); % 吡啶类
    if py 
       sml_ts = 'c1ccncc1';
       if  (A6==1)&&(AN==1)&&(N6+N5+N4+N3+N2+N1==0)&& (A4==0)
           sml_ts = 'c1ccncc1';% 吡啶
       elseif (A6==1)&&(A4>=1)&&(AN==1)&&(N6+N5+N4+N3+N2+N1==0)
           sml_ts = 'c1cccc2cccnc12';% 喹啉
       elseif  (A6>=2)&&(A4>=1)&&(AN==1)&&(N6+N5+N4+N3+N2+N1==0)   
           % BENZOQUINOLINE
           sml_tc = 'C1=CC=C2C(=C1)C=CC3=C2N=CC=C3';% 苯并喹啉
           % sml_tc = 'c1ccc2c(c1)ccc3=c2nccc3';% 苯并喹啉
       else 
           sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'N'];
           flag = 1;
       end
       return
    end         
        %% 胺类
       amine = (RN~=0) && (hetero-RN==0);
       if amine 
           % 在烷烃的基础上增加
           % NC1=CC=CC=C1  % Nc1ccccc1 苯胺
           sml_ts = 'NC1=CC=CC=C1';
           if A6+A4+A2+N6+N5+N4+N3+N2+N1==0
               % 构造脂肪胺
               sml_tc = solp2smlp(R);
               sml_ts = insertBefore(sml_tc,1,'N');% SOL 不能构造三乙胺类分子
           elseif (A6+A4+A2~=0)&&(N6+N5+N4+N3+N2+N1==0)
               % 构造苯胺类
               sml_ts = 'NC1=CC=CC=C1';% 苯胺
           elseif (A6+A4+A2==0)&&(N6+N5+N4+N3+N2+N1~=0)
               % 构造环胺 
               if N5~=0
                   sml_ts = 'C1CCC(C1)N';
               elseif N6~=0
                   sml_ts = 'C1CCCC(C1)N';
               end
           end
           return
       end
    %% 两种官能团组合

elseif hetero == 2
    %% 联苯噻吩 2017-12-22
    %Jthiophene S1C=CC2=CC(C4=CC=C5(CCS5)C45=C4)=C3C23=C12
    JBthio= (S==2)&(hetero-S ==0);
    
    if JBthio
        JBthiophene = ((A6==2)&&(AA==1)&&(H==-2)&&(N3>=2)&&(S==2));
        if JBthiophene
            sml_ts = 'S1C=CC2=CC(C4=CC=C5(CCS5)C45=C4)=C3C23=C12';% 联苯并噻吩？
        else
            %sml_tc = '联苯并噻吩';
            sml_ts = ['C',num2str(carbon_t),'H',num2str(hydron_t),'S',num2str(S)];
            flag = 1;
        end
        return
    end
    % 有机酸
     organic_acid = (RO==1)&(O_==1)&(hetero-(RO+O_)==0);
     if organic_acid
         if (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&&(br == 0)
             sml_tc = solp2smlp(R);
             slen = length(sml_tc);
             sml_ts = insertAfter(sml_tc,slen,'(=O)O');
         elseif (A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&&(br ~= 0)
             sml_tc = soli2smli(R,br);
             slen = length(sml_tc);
             sml_ts = insertAfter(sml_tc,slen,'(=O)O');
         elseif (A6+A4+A2==0)&&(N6+N5+N4+N3+N2+N1~=0) 
             sml_tc = 'C1CCCCC1';
             sml_ts = insertBefore(sml_tc,1,'O=C(O)');
         elseif (A6+A4+A2~=0)&&(N6+N5+N4+N3+N2+N1==0) 
             sml_tc = 'c1ccccc1';
             sml_ts = insertBefore(sml_tc,1,'O=C(O)');
         elseif (A6+A4+A2~=0)&&(N6+N5+N4+N3+N2+N1~=0) 
             sml_ts = 'C1CC(=O)C2=C1CC=C(C=C2)O';
         end
         return
     end
    
%% 三种官能团
elseif hetero == 3    
    thio_acidy = (RO==1)&(O_==1)&(S==1);
    if thio_acidy && (hetero-(RO+O_+S)==0)
        sml_ts = 'S1CC(C(=O)O)CCC1';
    end
    return
end


%% 子函数
%%
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

%% 构造长直链取代基 
function rp = solrp(rl)
         longbr = solp2smlp(rl);
         longbr_lc = insertBefore(longbr,1,'(');
         rp = insertAfter(longbr_lc,rl+1,')');
end
%% 构造长异构链取代基
function rpi = solri(r,rm)
         longbr = soli2smli(r,rm);
         longbr_lc = insertBefore(longbr,1,'(');
         rpi = insertAfter(longbr_lc,r+1,')');
end
%% 构造脂肪族烯烃SMILES
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

%% 构造脂肪族双烯烃
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
       
    %% 构造环烷烃
    function cycalk = solck2sml()
        cycalk = 'C1CCCCC1';
    end
%% 构造重复单元
    function mainch = solmc2smc(brm,strn)
            %meunit = 'c(c)';
            mainch_a = repmat(strn,1,brm);% 先构成c(c)....c(c)
            mainch = ['C',mainch_a,'C'];
    end
end