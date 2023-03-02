sola = xlsread('test.xlsx','Sheet1','B3:Y3');
%smlmat = cell(1);
sc = SOLCN;
sh = SOLHN;
[flag,sml_ts,erro] = solRng1_3(sola,sc,sh);
