
% version: 1.0
% date : 2017-11-18
% author: chen hui
% description: SOL convert to SMILES
%% 
solvec = zeros(1,24); % sol ����
solvec(:,10) = 6;
solvec(:,13) = 1;
carbon = sum(solvec.*SOLCN); % the number of carbon atoms
hydron = sum(solvec.*SOLHN); % the number of hydrongen atoms
%tt = mod(hydron,carbon); % 
%ttf = floor(hydron./carbon)

    satom = sum(:,15:24); %�ж���������Ԫ�أ���S��N��O��
    if satom == 0
        hrs = hydron - 2*carbon;
        if hrs == 2  % �ж��Ƿ��Ǳ�����
            brsol = solvec(11);
            rsol = solvec(10); % R��Ԫ�����Ŀ�����칹̼����
            if brsol>0 % ����֧���׻�
                
            else %��ֱ��
                smlp = solp2smlp(carbon);
            end
        end
    end
 %% ������������SMILES����
function paraffin = solp2smlp(carn)
    a = 'c';
    paraffin = repmat(a,1,carn);
end
%% ����֧��
function mainch = solmc2smc(brm,strn)
            %meunit = 'c(c)';
            mainch_a = repmat(strn,brm);% �ȹ���c(c)....c(c)
            mainch = ['c',mainch_a,'c'];
end
 %% �����칹����SMILES����
function isopafin = soli2smli(icarn,brn)
% icarn С��4 û���칹��
% brn>0 ������ڴ��ж�
    if icarn >= 4 
        mcarb = icarn - brn;
        % ����brn�루icarn-2���ıȽ��ж��١��塢��̼����Ŀ
        brme = icarn-2;
        brcyc = floor(brn./brme);% brcyc �����2
        brsme = mod(brn,brme);% brsme С��brme
        if brcyc ==0 
            % ���Ϊ��̼
            %pafin = solp2smlp(mcarb); % ��������
            %pafin = insertAfter(pafin,2,'(c)'); % ��һ�β���'��c��'
            for i = 1:brn
                pafin = insertAfter(pafin,2+(i-1).*4,'(c)');
            end
            % �׻���������
        elseif brcyc == 1 && brsme == 0
            meunit = 'c(c)';
            pafin = solmc2smc(brme,meunit);
        elseif brcyc==1 && brsme >0 
            me_unit = 'c(c)';
            pafin = solmc2smc(brme,me_unit);
            for i = 1:brsme
                pafin = insertAfter(pafin,5+(i-1).*4,'(c)');
            end
        elseif brcyc == 2 && brsme == 0
            tert_unit = 'c(c)(c)';
            pafin = solmc2smc(brme,tert_unit);
        else
            fprintf('excceding the branch limits!');
            return
        end
    else
        fprintf('the carbon number is less than 4, no matching SMILES!');
        return        
    end
end

