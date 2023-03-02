% 试验自动生成sol向量，以萘为例
data = xlsread('sol.xlsx','Sheet1','O85:AH104'); % 苝
%data = xlsread('sol.xlsx','Sheet1','O21:X30'); % 萘
dataA6 = xlsread('sol.xlsx','Sheet1','B11:G16'); % A6;
dataA4 = xlsread('sol.xlsx','Sheet1','B20:E23'); % A4;
lamda = eig(data); % 特征值
p = poly(data); % 特征多项式
r = roots(p);
[v,d] = eig(data);
sumla = sum(lamda.^2);
%data(2,3)=0;
%data(3,2)=0;
%data(5,6)=0; % break the ring and name C+num
%data(6,5)=0;
%data(10,17)=0; % break the ring and name C+num 断开的边 的顶点标记为环的起点和端点
% data(17,10)=0;
% data(14,13)=0;
% data(13,14)=0;
% data(15,16)=0;
% data(16,15)=0;
gh = digraph(data);
udgh = graph(data);
% plot(gh)
% hold on 
plot(udgh)
dv= dfsearch(udgh,3);
sol = zeros(1,24);
[rA6,mA6]=subgraph2(dataA6,data);
[s,h] = find(mA6==1);
if rA6 == 1
    sol(1)=1;
    graph_r = graphDeleteR(data,s);
    graph_new = graphDeleteC(graph_r,h);
    [rA4,mA4]=subgraph2(dataA4,graph_new);
    if rA4==1
      sol(2)=1;  
    end
end

function newGraph=graphDeleteR(gdta,row)
n = size(row,1);
k = 1:n;
gdta(k,:)=[];
newGraph = gdta;
end
function newGraph=graphDeleteC(gdta,colm)
n = size(colm,1);
k = 1:n;
gdta(:,k)=[];
newGraph = gdta;
end