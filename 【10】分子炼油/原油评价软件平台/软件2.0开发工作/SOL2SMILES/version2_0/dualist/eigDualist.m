%% 计算矩阵的特征值和特征向量
HM = hematrix;
lamda = eig(HM); % 特征值
p = poly(HM); % 特征多项式
[v,d] = eig(HM);
