%% A6 线性变换特征值
%data = xlsread('sol.xlsx','Sheet1','O21:X30'); % 萘
%data = xlsread('sol.xlsx','Sheet1','B11:G16');% 苯
% data = xlsread('sol.xlsx','Sheet1','O33:AB46');% 蒽
 data = xlsread('sol.xlsx','Sheet1','O49:AB62'); % 菲

lamda = eig(data); % 特征值
p = poly(data); % 特征多项式
r = roots(p);
[v,d] = eig(data);
sumla = sum(lamda.^2);
data(2,3)=0;
data(3,2)=0;
data(5,6)=0; % break the ring and name C+num
data(6,5)=0;
data(9,10)=0; % break the ring and name C+num 断开的边 的顶点标记为环的起点和端点
data(10,9)=0;
gh = digraph(data);
plot(gh)
dv= dfsearch(gh,2)