% 批量生成smiles
%% 2017-12-16
sola = xlsread('jjsol1t.xlsx','Sheet1','B2:Y10001');
smlmat = cell(10000,1);
sc = SOLCN;
sh = SOLHN;
for i = 1:10000
    smlmat{i} = solRng1_0(sola(i,:),sc,sh);
end