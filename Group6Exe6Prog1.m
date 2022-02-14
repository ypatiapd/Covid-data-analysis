%Apo to erwtima 5 exoume siberanei oti oi xwres pou sysxetizontai
%perissotero me tin ellada einai prwta i kipros me deikti thetikotitas 0.8
%kai simantiko elegxo se epipedo 0.01 kai epeita h tsexia me deikti
%thetikotitas 0.8 kai simantiko elegxo se epipedo 0.05.
%Let the CC of Greece and Cyprus be AB and the CC of Greece and Czechia be AC

clc;
clear;

[numbers, TEXT, everything] = xlsread('ECDC-7Days-Testing.xlsx');
[numbers, TEXT, countries] = xlsread('EuropeanCountries.xlsx');
[numbers, TEXT, greece] = xlsread('FullEodyData.xlsx');

countrycodes = cell2mat(countries(2:end,1));
countrynames = countries(2:end,2);
date = everything(2:end,3);
scale = everything(2:end,4);
positivity_idx = cell2mat(everything(2:end,11));
nations = everything(2:end,1);
[m,n] = size(date);

cases = cell2mat(greece(2:end,2));
pcrs = cell2mat(greece(2:end,46));
rapids = cell2mat(greece(2:end,45));
greek_weeks =string(greece(2:end,51));

greek_pidx=zeros(13,1);

for i=1:length(pcrs)
    if  strcmp(greek_weeks(i),'2021-W38')
        for j=0:12
            sumcases = 0;
            sumtests = 0;
            for z=0:6
                sumcases = sumcases + cases(i + j*7 + z);
                sumtests = sumtests + pcrs(i+z+j*7)-pcrs(i+z-1+j*7)+rapids(i+z+j*7)-rapids(i+z-1+j*7);
            end
            greek_pidx(j+1,1) = (sumcases / sumtests)*100;
        end
        break;
    end
end

pos_idx_2021=zeros(13,2);
for z = 5:6       
    for i=1:m
        if strcmp(nations(i), string(countrynames(z))) && strcmp(scale(i,1), 'national') && strcmp(date(i,1), '2020-W38')
            for j=0:12
                pos_idx_2021(j+1,7-z) = positivity_idx(i+j,1);
            end
            break;
        end
    end
end

 AB=[greek_pidx,pos_idx_2021(:,2)]; % Greece-Cyprus
 AC=[greek_pidx,pos_idx_2021(:,1)]; % Greece-Czechia
 
 
%%Random permutation
sample_R1=corrcoef(greek_pidx,pos_idx_2021(:,1));
sample_R2=corrcoef(greek_pidx,pos_idx_2021(:,2));

sample_diff=sample_R1(1,2)-sample_R2(1,2);

n=length(AB(:,1));
pool = cat(1,AB,AC) ;
B=1000;
diff_r=zeros(B,1);
for i=1:B
    a=randperm(2*n);
    pool=pool(a,:);
    X=zeros(n,2);
    X=pool(1:n,:);
    Y=zeros(n,2);
    Y=pool(n+1:end,:);
    [R1,P1,RL1,RU1]  = corrcoef(X(:,1),X(:,2));
    [R2,P2,RL2,RU2]  = corrcoef(Y(:,1),Y(:,2));
    diff_r(i)=R1(1,2)-R2(1,2);
end

zero_diff = 0;
figure(1)
clf
bins = 20;
histogram(diff_r);
xline(zero_diff,'r');
hold on
ylabel('Random permutation Samples')
xlabel('Correlation coefficient difference of AB and AC ')
title('Random permutation equality test for correlation coefficients of AB and AC ')

% Gia ton elegxo isothtas twn suntelestwn susxetishs anamesa se
% Ellada-Kurpo kai Ellada-Tsexia , arxika enwnoumse se enan pinaka oles tis
% zeugarwtes parathrhseis pou aforoun deiktes 8etikothtas antistoixwn
% ebdomadwn. Epeita, antistoixa me thn askhsh gia elegxo isothtas meswn
% timwn anakateuoume to koino pool twn zeugarwtwn parathrhsewn me random
% permutation upo8etontas pws oi zeugarwtes parathrhseis exoun koino suntelesth
% kai xwrizoume to neo pool sta duo. To prwto miso antistoixei
% se upo8etikes zeugarwtes parathrhseis deiktwn 8etikothtas gia
% Ellada-Kupro kai to deutero gia Ellada-Tsexia. Ypologizoume thn diafora
% twn suntelestwn susxetishs gia ta duo nea deigmata , B fores , kai
% apeikonizoume se istogramma. To 0 brisketai entos tou diasthmatos
% empistosunhs kai epomenws h upo8esh gia isothta den mporei na aporrif8ei.
