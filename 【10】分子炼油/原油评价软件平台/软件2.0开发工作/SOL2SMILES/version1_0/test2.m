sola = xlsread('test.xlsx','Sheet1','B3:Y3');
%smlmat = cell(1);
sc = SOLCN;
sh = SOLHN;
smlmat = sml(sola,sc,sh);
