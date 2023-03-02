% 批量生成smiles
%% 2017-11-24
sola = xlsread('jjsol1t.xlsx','Sheet1','B2:Y10001');
smlmat = cell(10000,1);
sc = SOLCN;
sh = SOLHN;
for i = 1:10000
    smlmat{i} = sml(sola(i,:),sc,sh);
end