    function ar2 = ar2Recur(bime) % bime = Å¼Êý
        if mod(bime,2) == 0
            bime = bime/2;
            if bime <=2
                %ar1 = '(c2c(C)cccc2)';
                artW = msRecur(bime,'c(C)');
                artE = msRecur(5-bime,'c');
                ar2 = ['c1',artW,artE,'1'];
            else
                art = ar2Recur(bime-1);
                ar2 = [art(1:12+(bime-3)*4),'(C)',art(13+(bime-3)*4:end)];
            end
        else
            bime = bime-1;
            ar2 = ar2Recur(bime);
        end
    end  