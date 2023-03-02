function [Y]=RNG(Comp)
load("COMP.mat");
%[Y] =CA(Comp) takes following argument:
%Comp demonsion nX24 Matrix/Vector
Comp(:,14)=floor(rem(Comp(:,14),10)); % 先判断是否含有AA结构单元
%→ Step 2 
k=[1:9,13:24];
COMP1=COMP(:,k);
Comp1=Comp(:,k);
ind=[];
for i=1:size(COMP,1)
    if COMP1(i,:)==Comp1
        ind=i;
    end
end
if isnan(ind)==0
    Z=[Rng_DATA(:,2.*ind-1),Rng_DATA(:,2.*ind)];
    if Comp==[0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 0 0 0 0]
        Z=[0 0];
    end
    Y=Z;
else
C=[4];% put forgotten structures in polars
A6=Comp(1);
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
 biphenyl=((A6==2)&(AA==1)&(hetero==0)&(N1==0));
 fluorene=((A6>=2)&(AA>=1)&(AA==N1));% 芴
 oddsul=((A4>=2)&(N1~=0)&(S~=0)&(AA==0));
 fluoranthene=((A6>=2)&(A4==1)&(AA==2)&(N4==0)&(N3==0));% 荧蒽
 fluoranthene=fluoranthene|((A6==1)&(A4>=3)&(AA==1));
 por=((N1==4)&(NN==4)&((N5+N3)==4));%-benzofluoranthene
% Determine cut:
%(saturates)    (aromatics+thiophenes)    (sulfides)    (polars)
%saturate hydrocarbons
J=(A6+A4+A2+hetero==0)&(N6+N5+N4+N3+N2+N1~=0)&(H==0); %naphthenes
J=J|((A6+A4+A2+hetero+N6+N5+N4+N3+N2+N1==0)&(R~=0)&(H==1));  %paraffin
J=J|((A6+A4+A2+hetero==0)&(N6+N5+N4+N3+N2+N1~=0)&(H<0));  %cyclo alkene
J(J==0)=[];
C(J)=1;

a2max=4;  %max value of A2s allowed in aromatics, sulfides
%aromatic+thiophenes
J=((A2<=a2max)&(hetero==0)&(A6+A4+A2~=0));  %aromatics
J=J|((H<0)&(N1+N2+N3+N4+N5+N6~=0)&(A6+A4+A2+hetero==0));  %cyclo alkene
J=J|((A6+A4+A2+hetero+N6+N5+N4+N3+N2+N1==0)&(R~=0)&(H<=0));  %alkene
J=J|((N6==0)&(A6==1)&(N1>=1)&(AA==1)&(S+O~=0)&(A2<=a2max));   %strange thiophenes
dibenzo=((A6>=2)&(N1>=1)&(AA>=1)&(O+S~=0)&(A2<=a2max)); %dibenzothiophenes & dibenzofurans
benzo=((A6>=1)&(H==-N3)&(N3>=1)&(O+S~=0)&(A2<=a2max));   %benzothiophenes & benzofurans
thio=((N5>=1)&(N3+N1==0)&(H<=-2)&(O+S~=0)&(A2<=a2max));   %thiophenes & furans
J=J|dibenzo|benzo|thio;
J=J|((A6>=2)&(N1>=1)&(AA>=1)&(NN>=1)&(A2<=a2max));   %carbazoles
J=J|((A6>=1)&(N1>=1)&(AA==0)&(NN>=1));   %carbazoles with bridging N1
J=J|((A6>=1)&(AA==0)&(H<=-1)&(N3>=1)&(NN>=1)&(A2<=a2max));   %indoles
J=J|((N5>=1)&(H<=-2)&(NN>=1)&(A2<=a2max));   %pyrroles
J=J&(acid+sulfoxide+RO==0)&(AN==0)&(~por);   %no acids or sulfoxides or alcohols
J(J==0)=[];
C(J)=2;

%sulfiodes
J=(S>=1)&(A6+A4+A2+N1+N2+N3+N4+N5+N6==0)&(H==1);   %acyclic sulfides
J=(S>=1)&(N1+N2+N3+N4+N5+N6~=0)&((-N3~=H)|J)&(C~=2);   %cyclic sulfides with multiple S but one sulfide
J=J|((A2<=a2max)&(S>=1)&(N1+N2+N3+N4+N5+N6==0)&(A2+A4+A6~=0));   %other
J=J|((A2<=a2max)&(O+S~=0)&(H<=-2)&(N1+N3==0)&(N5>=1));   %thiophenes & furans
J=J|((A2<=a2max)&(NN>=1)&(AA>=1)&(N1>=1)&(A6>=2));   %carbazoles
J=J|((A2<=a2max)&(NN>=1)&(N3>=1)&(H<=-1)&(N1==0)&(A6>=1));   %indoles
J=J|((A2<=a2max)&(NN>=1)&(H<=-2)&(N5>=1));   %pyrroles
J=J&(AN==0)&(~por)&(acid+sulfoxide==0);  %no acids or sulfoxides
if J==1
    C=[3,C];
end
% polars
J=AN>=1;
J=J|((A2>=a2max));
J=J|((RN>=1));
J=J|((RO>=1));
J=J|((por==1));
J=J|acid|sulfoxide;
if J==1
    C=[4,C];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%determine fraction within cut
ROLD=[];
[~,ncloumn]=size(C);
for n=1:ncloumn
    if C(n)==1
        Rold=[1 1];
    end
   if C(n)==2
        J=(C(n)==2)&(NN==0);
        if J==1
            indexNN=max(1,min(4,(((~biphenyl)*A6+A4)+(2*biphenyl)+A2+S+O+fluoranthene+oddsul+(fluorene*(O+S==0))-((AA==0)&(N1==1)|((N2==1)&(AA~=0))))));
            Rold=[2,indexNN];
        elseif J==0
            Rold=[2,4];
        end
   end
   if C(n)==3
        J=(C(n)==3)&(NN+RO==0);
        if J==1
            Rold=[3,min(1,A6+A4+A2+2)];
        elseif J==0
            Rold=[3,1];
        end
   end
    if C(n)==4
        Rold=[4,1];
    end
    ROLD=[Rold;ROLD];
end
Y=ROLD;
end

        
     