clc;
clear;

AEM = 8606;
Cnum = mod(AEM,25) + 1;
Cnum;
 
[numbers, TEXT, countries] = xlsread('EuropeanCountries.xlsx');
[numbers, TEXT, everything] = xlsread('ECDC-7Days-Testing.xlsx');
length(everything);
size(everything,1);

countrycodes = cell2mat(countries(2:end,1));
countrynames = countries(2:end,2);

date = everything(2:end,3);
scale = everything(2:end,4);
positivity_idx = cell2mat(everything(2:end,11));
country = everything(2:end,1);
[m,n] = size(date);
last2020 = [];
countries2020 = [];
countries2021 = [];
last2021 = [];
s1 = '2020-W50';
s2 = 'national';

for i=1:length(countrynames)
    if countrycodes(i) == Cnum
            CountryA = string(countrynames(i));
    end
end

max = 0;
counter2020 = 0;

for i = 1:m
    if strcmp(date(i) ,'2020-W45') && strcmp(scale(i), 'national') && strcmp(country(i) , CountryA)
        for j = i:(i+5)
            if positivity_idx(j) > max
                counter2020 = j -i ;
                max = positivity_idx(j);
            end
        end
        break;
    end
end

max = 0;
counter2021 = 0;

for i = 1:m
    if strcmp(date(i) , '2021-W45') && strcmp(scale(i) , 'national') && strcmp(country(i) , CountryA)
        for j = i:(i+5)
            if positivity_idx(j) > max
                counter2021 = j -i ;
                max = positivity_idx(j);
            end
        end
        break;
    end
end


for i = 1:m
    if strcmp(date(i), '2020-W45') && strcmp(scale(i) , 'national')
        last2020 = [last2020,positivity_idx(i + counter2020)];
        countries2020 = [countries2020,country(i)];
    end
    if strcmp(date(i) , '2021-W45') && strcmp(scale(i) , 'national')
        if ismember(country(i),countries2020)  
            last2021 = [last2021,positivity_idx(i+counter2021)];
            countries2021 = [countries2021,country(i)];
        else
            continue;
        end
    end   
end

[d pd] = allfitdist(last2020,'PDF');
title('Top 5 distributions that fit 2020-WEEK50 positivity index')

[d pd] = allfitdist(last2021,'PDF');
title('Top 5 distributions that fit 2021-WEEK50 positivity index')

figure(3)
clf;
histfit(last2020,5,'Exponential');

ylabel('No of Countries')
xlabel('Positivity index')
title('Fit of Positivity index to Exponential Distribution Week50 of 2020')

figure(4)
clf;
histfit(last2020,5,'Nakagami');

ylabel('No of Countries')
xlabel('Positivity index')
title('Fit of Positivity index to Nakagami Distribution Week50 of 2021')


% Arxika, dokimasame na prosarmosoume ton deikth 8etikothtas se kanonikh kai
% ek8etikh katanomh kai gia tis duo bdomades (50h twn etwn 2020 kai 2021)
% kai parathroume pws o deikths 8etikothtas gia to 2020 prosarmozetai kala 
% sthn ek8etikh katanomh , pragma pou den isxuei omws gia to 2021 opou o
% deikths prosarmozetai kalutera sthn kanonikh katanomh alla oxi veltista
% sthrizontas tis ektimhseis mas sta diagrammata. Sth sunexeia 
% xrhsimoipoihsame thn allfitdist , sunarthsh pou dokimazei na prosarmosei 
% praktika oles tis katanomes sthn empeirikh mas katanomh kai katalh3ame
% pws h ek8etikh tairiazei sthn bdomada mas gia to 2020 , enw h nakagami
% sthn bdomada gia to 2021.




