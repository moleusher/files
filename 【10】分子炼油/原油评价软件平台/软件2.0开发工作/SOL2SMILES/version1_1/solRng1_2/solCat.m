%% SOL 2 smiles 
% ��sol�������з��������ж�
% CompΪ����SOL����
    A6=Comp(1); % ��ȡ���ṹ��Ԫ
    A4=Comp(2);
    A2=Comp(3);
    N6=Comp(4);N5=Comp(5);N4=Comp(6);
    N3=Comp(7);N2=Comp(8);N1=Comp(9);
    R=Comp(10);br=Comp(11);me=Comp(12);
    H=Comp(13);AA=Comp(14);S=Comp(15);
    RS=Comp(16);AN=Comp(17);NN=Comp(18);
    RN=Comp(19);O=Comp(20);RO=Comp(21);
    O_=Comp(22);Ni=Comp(23);V=Comp(24);
    hetero=O_+RO+O+RN+NN+AN+RS+S;% ���������
    paraffin = (hetero+AA+A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&(R~=0)&(H==1); % ������
    olefin = (hetero+AA+A6+A4+A2+N6+N5+N4+N3+N2+N1==0)&(R~=0)&(H==0);% ֬����ϩ��
    cyc_pentane = (hetero+AA+A6+A4+A2+N6+N4+N3+N2+N1==0)&(N5~=0)&(H==0);% ������
    cyc_pentene = (hetero+AA+A6+A4+A2+N6+N4+N3+N2+N1==0)&(N5~=0)&(H<0);% ����ϩ H == -2?
    cyc_hexane = (hetero+AA+A6+A4+A2+N5+N4+N3+N2+N1==0)&(N6~=0)&(H==0);% ������
    cyc_hexene = (hetero+AA+A6+A4+A2+N6+N4+N3+N2+N1==0)&(N6~=0)&(H<0);% ����ϩ H == -1?
    hyd_indane = (hetero+AA+A6+A4+A2+N5+N4+N2+N1==0)&(N6==1)&(N3~=0);% �⻯����
    hyd_chrysane = (hetero+AA+A6+A4+A2+N5+N3+N2+N1==0)&(N6==1)&(N4~=0)&(H==0);% �⻯?��  %phenanthrene ��
    hyd_chrysene = (hetero+AA+A6+A4+A2+N5+N3+N2+N1==0)&(N6==1)&(N4~=0)&(H<0);
    hyd_pyrene = (hetero+AA+A6+A4+A2+N5+N2+N1==0)&(N6==1)&(N4~=0)&(N3~=0)&(H==0);%�⻯��
    benzene = (hetero+AA+A4+A2+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(H==0);%��
    benzene_o = (hetero+AA+A4+A2+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(H==-1);%ϩ������
    indane = (hetero+AA+A4+A2+N6+N5+N4+N2+N1==0)&(A6==1)&(N3~=0);%��
    hydr_naphthalene = (hetero+AA+A4+A2+N6+N5+N3+N2+N1==0)&(A6==1)&(N4~=0);%���ı���
    hydr_pyrene_benz = (hetero+AA+A4+A2+N6+N5+N2+N1==0)&(A6==1)&(N4~=0)&(N3~=0);%�⻯��
    naphthalene = (hetero+AA+A2+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(A4~=0);%��
    phenanthrene = (hetero+AA+A2+N6+N5+N4+N3+N2==0)&(A6==1)&(A4~=0)&(N1==1);%
    acenaphthene = (hetero+AA+A2+N6+N5+N4+N3+N1==0)&(A6==1)&(A4~=0)&(N2==1);%��
    pyrene_benzo = (hetero+AA+A2+N6+N5+N4+N2+N1==0)&(A6==1)&(A4~=0)&(N3~=0);%�⻯��
    chrysene_benzo = (hetero+AA+A2+N6+N5+N4+N2+N1==0)&(A6==1)&(A4~=0)&(N4~=0);
    benzopyrene_p = (hetero+AA+N6+N5+N4+N3+N2+N1==0)&(A6==1)&(A4~=0)&(A2~=0);
    diphenylmethane = (hetero+AA+N6+N5+N4+N3+N2==0)&(A6==2)&(N1~=0);%����������
    indene_phylm = (hetero+AA+N6+N5+N4+N2==0)&(A6==2)&(N3~=0)&(N1~=0);%���׻��� 23
    naphene_phylm = (hetero+AA+N6+N5+N3+N2==0)&(A6==2)&(N4~=0)&(N1~=0);%���׻��� 24
    bicyclohexyl = (hetero+A4+A2+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==0)&(N6~=0);% ��������
    cychexyl_hydnaphene = (hetero+A4+A2+N5+N3+N2+N1==0)&(AA==1)&(A6==0)&(N6~=0)&(N4~=0);% 
    benzcyclohexyl = (hetero+A4+A2+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==1)&(N6~=0);% 
    fluorene_hyd = (hetero+A4+A2+N5+N4+N3+N2==0)&(AA==1)&(A6==1)&(N6~=0)&(N1~=0);%��
    biIndane = (hetero+A4+A2+N5+N4+N2+N1==0)&(AA==1)&(A6==1)&(N6~=0)&(N3~=0);%
    naphyl_hnaphene = (hetero+A4+A2+N5+N3+N2+N1==0)&(AA==1)&(A6==1)&(N6~=0)&(N4~=0);%
    benzopyrene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==1)&(A4~=0);% 
    biphenyl = (hetero+A4+A2+N6+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==2);% 
    fluorene = (hetero+A4+A2+N6+N5+N4+N3+N2==0)&(AA==1)&(A6==2)&(N1~=0);% 
    bih_phenanthrene = (hetero+A4+A2+N6+N5+N4+N3+N1==0)&(AA==1)&(A6==2)&(N2~=0);%�����
    phyl_hnaphene = (hetero+A4+A2+N6+N5+N3+N2+N1==0)&(AA==1)&(A6==2)&(N4~=0);
    phyl_fluorene = (hetero+A4+A2+N6+N5+N3+N2==0)&(AA==1)&(A6==2)&(N4~=0)&(N1~=0);
    h_chrysene = (hetero+A4+A2+N6+N5+N3+N1==0)&(AA==1)&(A6==2)&(N4~=0)&(N2~=0);
    phyl_naphene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==1)&(A6==2)&(A4~=0);% 
    naphyl_naphene = (hetero+A2+N6+N5+N3+N2+N1==0)&(AA==1)&(A6==2)&(A4~=0)&(N4~=0);% 
    phyl_cycheyl_fluorene = (hetero+A2+N6+N5+N3+N2==0)&(AA==1)&(A6==2)&(A4~=0)&(N4~=0)&(N1~=0);% 
    h6_Picene = (hetero+A2+N6+N5+N3+N1==0)&(AA==1)&(A6==2)&(A4~=0)&(N4~=0)&(N2~=0);% 
    fluoranthene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==1);% ӫ��
    h4_Perylene = (hetero+A2+N6+N5+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==1)&(N4~=0);% �����p
    perylene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==2);%�p
    benzo_4hperylene = (hetero+A2+N6+N5+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==2)&(N4~=0);% ���������p
    benzo_perylene = (hetero+A2+N6+N5+N4+N3+N2+N1==0)&(AA==2)&(A6==2)&(A4==3);% ���������p
    %������������������������������������������������������������������������
    %% 
    % �ӻ�����
    
    %% �ж����ͣ����smiles
    if paraffin
        if br>0
              %sml_ts = soli2smli(R,br); %�����칹���� SMILES
              sml_ts = isoRecur(R-br,br);
        else
              %sml_ts = solp2smlp(R); % ������������ SMILES
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
    %% �ݹ鷨�����칹����SMILES
    function isopafin = isoRecur(iR,brc)
        if brc == 1
            smlp = msRecur(iR-1,'C');
            isopafin = [smlp,'(C)C'];  
        elseif (iR-2)>=brc % �����ͷ�ļ׻�̼��ֻ��Rc-2����̼������̼����brc,��brc����̼���Ա�Ϊ��̼��ʣ��Rc-brc-1Ϊ��̼,���һ�����ǲ�̼
            smlc = msRecur(brc,'C(C)');
            smlp = msRecur(iR-1-brc,'C');
            isopafin = ['C',smlc,smlp];
        else
            Rt = iR + brc;
            if brc>fix((2*Rt-4)/3)
                brc=fix((2*Rt-4)/3); % Rc-2 ��̼С��brc������brc-(Rc-2)����̼���Ϊ��̼
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
    %% ����ȡ����
% �ݹ��㷨�����֧����ȡ����
% Rc = R - br ʣ��̼
function sub = subRecur(Rc,brc)
    if brc == 1
        smlp = msRecur(Rc,'C');
        sub = [smlp,'(C)'];  
    elseif (Rc-1)>brc % �����ͷ�ļ׻�̼��ֻ��Rc-1����̼������̼����brc,��brc����̼���Ա�Ϊ��̼��ʣ��Rc-brc-1Ϊ��̼,���һ�����ǲ�̼
        smlc = msRecur(brc,'C(C)');
        smlp = msRecur(Rc-brc,'C');
        sub = [smlp,smlc];
    else % Rc-1 ��̼С��brc������brc-(Rc-1)����̼���Ϊ��̼
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
function ms = msRecur(R,carbon) % carbon ���� char
    if R ==0
        ms = [];
    elseif R ==1
        ms = carbon;
    else
        ms = [msRecur(R-1,carbon),carbon];
    end
     %return
end