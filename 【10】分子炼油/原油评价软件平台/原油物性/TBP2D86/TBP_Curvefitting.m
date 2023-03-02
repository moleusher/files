%Load TBP DATA
[~,~,TBPCutFBP]=xlsread('Tune_test九江53.xls',1,'DJ3:DJ150');
[~,~,TBPCutYieldWt]=xlsread('Tune_test九江53.xls',1,'DK3:DK150');
%Convert Yield to CumulaYield & Convert cell to matrix
YieldWt=cell2mat(TBPCutYieldWt);
Tb=cell2mat(TBPCutFBP);
Wt=cumsum(YieldWt);
%Convert units
C2R=@(x) (x+273.15)*9/5;%%Celsius to Rankine
T=C2R(Tb);
R2C=@(x) x*5/9-273.15;%%Rankine to Celsius
%Rebulid matrix，remove yield=0 & NaN & yield>=100
A=find(Wt~=0&~isnan(T)&Wt<100);
T=T(A);
Wt=Wt(A);
%Preparing for iteration
X=log(log(1./(1-Wt./100)));
AverageX=mean(X);
squaredX=X.^2;
[nrowsX,ncloumnsX]=size(X);
[nrowsT,ncloumnsT]=size(T);
if nrowsX~=nrowsT
    fprint('Error')
else
end
%start iteration
T0=0;
n=0;%%initial point of iteration, and "n" is the number of loops
ArrayRSS=[];ArrayAT=[];ArrayBT=[];ArrayT0=[];%%Recording the results of each loops by Arrays
while T0<min(T)
T0=T0+0.01;
Y=log((T-T0)./T0);
AverageY=mean(Y);
%regression
C=(sum(X.*Y)-(nrowsX.*AverageX.*AverageY))/(sum(squaredX)-(nrowsX.*AverageX.*AverageX));
D=AverageY-AverageX.*C;
BT=1./C;
AT=BT.*exp(D.*BT);
RS=((T0+T0.*((AT./BT.*log(1./(1-Wt./100))).^(1./BT)))-T).^2;
RSS=sum(RS);
%Data collecting.
ArrayRSS=[ArrayRSS,RSS];
ArrayAT=[ArrayAT,AT];
ArrayBT=[ArrayBT,BT];
ArrayT0=[ArrayT0,T0];
n=n+1;
end
[minx, ind] = min(ArrayRSS);
RSS=ArrayRSS(ind),AT=ArrayAT(ind),BT=ArrayBT(ind),T0=ArrayT0(ind)
y=T0+T0.*(((AT./BT.*log(1./(1-Wt./100))).^(1./BT)));
plot(Wt,T,Wt,y);
 TBP=@(x) T0+T0.*(((AT./BT.*log(1./(1-x./100))).^(1./BT)));
 Z=R2C([TBP(10),TBP(30),TBP(50),TBP(70),TBP(90)]) %unit:°C 
IBP= input('馏分段TBP=（0）');
disp(['IBP=',num2str(IBP)]);
FBP= input('馏分段FBP=（0）');
disp(['FBP=',num2str(FBP)]);
 
 