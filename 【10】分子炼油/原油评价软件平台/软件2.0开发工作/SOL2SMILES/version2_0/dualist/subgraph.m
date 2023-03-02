% Ullmann Algorithm
M = M0;
F = zeros(1:palpha); % 子图
H = zeros(1:pbeta);% 图
d = 1; % 第一个顶点
if JExist(M,F,d)
    Md = M;
    K=1;
end
if M(d,k)==0 || F(k)==1 % 该K列已经使用
    K = K + 1;
else
    j = [1:K-1,(K+1):pbeta]; % K >=2
    M(d,j)=0;
end  
H(1)=K;
F(K)=1;
for d = 2:palpha % while d <= palpha
   if JExist(M,F,d)
      Md = M;
      for K = 1:palpha
          if M(d,K)==0 || F(K)==1 % 该K列已经使用
            return
          else
            j = [1:K-1,(K+1):pbeta]; % K >=2
            M(d,j)=0;
          end 
      end
   elseif d~=1
      d = d-1;
      F(K)=0;
      K=H(d);
      M=Md;
      if (M(d,K+1:end)==1) .* F(K+1:end)
          M=Md;
          K = K+1;
          
      end
   end   
end

%k = k +1;

%% 判断是否存在j使得M(d,j)==1 && F(j)==0
function jbool = JExist(M,F,d)
    jbool = 1; % false 不存在
    n = size(M,2);
    for i = 1:n
        if M(d,i)==1 && F(i)==0
            jbool = 0; % ture 存在
        end
    end
    %(M(d,i)==1)
end