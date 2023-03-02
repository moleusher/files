function [Y] =CA(Comp)
%[Y] =CA(Comp) takes following argument:
%Comp demonsion 1X24 Matrix/Vector
carbon=sum(Comp.*[6 4 2 6 5 4 3 2 1 1 0 0 0 0 -1 0 -1 -1 0 -1 0 0 0 0]);
A=sum(Comp(:,1:9));
if A~=0
    Rings=1;
else
    Rings=0;
end
F=((Comp(:,13)==0).* (~Rings)+(-min(Comp(:,13),0).*Rings)).*2;
%Output
Y=(F+Comp(:,1)*6+Comp(:,2)*4+Comp(:,3)*2-Comp(:,17))/(max(carbon,1));
end
