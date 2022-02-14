clc;
clear;

AEM = 8606;
Cnum = mod(AEM,25) + 1;
Cnum;
[numbers, TEXT, everything] = xlsread('ECDC-7Days-Testing.xlsx');
[numbers, TEXT, countries] = xlsread('EuropeanCountries.xlsx');
[numbers, TEXT, greece] = xlsread('FullEodyData.xlsx');
length(everything);
size(everything,1);

alpha1 = 0.01;
alpha2 = 0.05;

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

for i=1:length(countrynames)
    if countrycodes(i) == Cnum
            CountryA = string(countrynames(i));
    end
end

greek_pidx=zeros(13,1);

for i=1:length(pcrs)
    if  strcmp(greek_weeks(i) , '2021-W38')
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

for z = Cnum-2:Cnum+2       
    pos_idx_2021=zeros(13,1);
    for i=1:m
        if strcmp(nations(i) , string(countrynames(z))) && strcmp(scale(i,1) , 'national') && strcmp(date(i,1), '2020-W38')   
            for j=0:12
                pos_idx_2021(j+1,1) = positivity_idx(i+j,1);
            end
            break;
        end
    end
        
    disp('Parametric Correlation Testing');
    [R,P,RL,RU]  = corrcoef(greek_pidx,pos_idx_2021);
    if (P(1,2)< alpha2)
        mes = sprintf('The null hypothesis that there is not a strong correlation between Greece and %s is rejected  for 0.05 level of confidence because our p-value is lesser than the former ',string(countrynames(z)));
        disp(mes)
        if (P(1,2)< alpha1)
            mes = sprintf('Additionally,the null hypothesis that there is not a strong correlation between Greece and %s is rejected  for 0.01 level of confidence because our p-value is lesser than the former',string(countrynames(z)));
            disp(mes)
        end
    else 
        mes = sprintf('The null hypothesis that there is not a strong correlation between Greece and %s is not rejected for 0.05 level of confidence because our p-value is greater than the former',string(countrynames(z)));
        disp(mes)
    end
    
    disp('Bootstrap correlation testing');
    B = 1000;
    sample_stat = R(1,2);
    n = length(pos_idx_2021);
    Rs = [];
    Rs = [Rs, sample_stat];
    
    for i=1:B
        
        a = randperm(n);
        mixed_eu = pos_idx_2021(a);
        R = corrcoef(greek_pidx,mixed_eu);
        Rs = [Rs,R(2,1)];
               
    end
    
    figure(z)
    clf
    bins = 20;
    histogram(Rs,bins);
    xline(sample_stat,'r');
    hold on
    ylabel('Frequency')
    xlabel('CorPerm')
    title('Correlation histogram of permutations between Greece and '+ string(countrynames(z)));

    Rs=sort(Rs);
    left_lim=round((alpha2/2)*(B+1));
    right_lim=round((1-alpha2/2)*(B+1));
    left=Rs(left_lim);
    right=Rs(right_lim);

    if sample_stat>left && sample_stat<right
       mes = sprintf('The hypothesis that there is not a strong correlation between Greece and %s is NOT rejected for 0.05 level of confidence because our sample estimation is NOT found on either tail of the distribution that comes from random permutation',string(countrynames(z)));
       disp(mes)
    else
       mes = sprintf('The hypothesis that there is not a strong correlation between Greece and %s is rejected for 0.05 level of confidence because our sample estimation is found on a tail of the distribution that comes from random permutation',string(countrynames(z)));
       disp(mes)
    end
    
    left_lim=round((alpha1/2)*(B+1));
    right_lim=round((1-alpha1/2)*(B+1));
    left=Rs(left_lim);
    right=Rs(right_lim);
    
    if sample_stat>left && sample_stat<right
       mes = sprintf('The hypothesis that there is not a strong correlation between Greece and %s is NOT rejected for 0.01 level of confidence because our sample estimation is NOT found on either tail of the distribution that comes from random permutation',string(countrynames(z)));
       disp(mes)
    else 
       mes = sprintf('The hypothesis that there is not a strong correlation between Greece and %s is rejected  for 0.01 level of confidence because our sample estimation is found on a tail of the distribution that comes from random permutation',string(countrynames(z)));
       disp(mes)
    end
          

end

 
 % Ta parapanw sumperasmata gia ton elegxo tuxaiopoihshs prokuptoun
 % analutikotera , apo to gegonos pws otan h empeirikh ektimhsh tou
 % suntelesth susxetishs apo to deigma einai makrua apo ta apotelesmata tou
 % permutation , mporoume me sigouria na poume pws enas suntelesths opws
 % autos pou metrhsame den mporei na parathrh8ei se mia periptwsh opou ta
 % zeugaria twn metablhtwn einai teleiws tuxaia.
 %  Katalhgoume telika sto sumperasma pws h Ellada parousiazei
 % isxurh susxetish oson afora ton deikth 8etikothtas me thn Kupro 
 % kai se deutero ba8mo me thn Tsexia.