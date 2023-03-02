
%% ����֧��

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
            pafin = solp2smlp(mcarb); % ��������
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
    isopafin = pafin;
    function mainch = solmc2smc(brm,strn)
            %meunit = 'c(c)';
            mainch_a = repmat(strn,brm);% �ȹ���c(c)....c(c)
            mainch = ['c',mainch_a,'c'];
    end

     %% ������������SMILES����
    function paraffin = solp2smlp(carn)
        a = 'c';
        paraffin = repmat(a,1,carn);
    end

end