% 苝 Perylene 的邻接矩阵及顶点遍历
%% 
% 2018-2-1
data = xlsread('sol.xlsx','Sheet1','O85:AH104'); % 苝
data2 = xlsread('sol.xlsx','Sheet1','B11:G16');
lamda = eig(data); % 特征值
p = poly(data); % 特征多项式
r = roots(p);
[v,d] = eig(data);
sumla = sum(lamda.^2);
data(2,3)=0;
data(3,2)=0;
data(5,6)=0; % break the ring and name C+num
data(6,5)=0;
data(10,17)=0; % break the ring and name C+num 断开的边 的顶点标记为环的起点和端点
data(17,10)=0;
data(14,13)=0;
data(13,14)=0;
data(15,16)=0;
data(16,15)=0;
gh = digraph(data);
udgh = graph(data);
% plot(gh)
% hold on 
plot(udgh)
dv= dfsearch(udgh,3);
r=subgraph2(data2,data)
