% ????????smiles
%% 2017-12-23
sola = xlsread('jjsol1t.xlsx','Sheet1','B2:Y10001');
smlmat = cell(10000,1);
flags = zeros(10000,1);
sc = SOLCN;
sh = SOLHN;
for i = 1:10000
    [flags(i),smlmat{i}] = solRng1_1(sola(i,:),sc,sh);
end