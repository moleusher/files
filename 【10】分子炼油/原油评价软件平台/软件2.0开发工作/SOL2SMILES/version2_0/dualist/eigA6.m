%% A6 ���Ա任����ֵ
%data = xlsread('sol.xlsx','Sheet1','O21:X30'); % ��
%data = xlsread('sol.xlsx','Sheet1','B11:G16');% ��
% data = xlsread('sol.xlsx','Sheet1','O33:AB46');% ��
 data = xlsread('sol.xlsx','Sheet1','O49:AB62'); % ��

lamda = eig(data); % ����ֵ
p = poly(data); % ��������ʽ
r = roots(p);
[v,d] = eig(data);
sumla = sum(lamda.^2);
data(2,3)=0;
data(3,2)=0;
data(5,6)=0; % break the ring and name C+num
data(6,5)=0;
data(9,10)=0; % break the ring and name C+num �Ͽ��ı� �Ķ�����Ϊ�������Ͷ˵�
data(10,9)=0;
gh = digraph(data);
plot(gh)
dv= dfsearch(gh,2)