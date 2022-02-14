clc;
clear;
AEM = 8606;
Cnum = mod(AEM,25) + 1;
Cnum;
[numbers, TEXT,greece] = xlsread( 'FullEodyData.xlsx' ) ;
[numbers, TEXT, countries] = xlsread('EuropeanCountries.xlsx');
countrycodes = cell2mat(countries(2:end,1));
countrynames = countries(2:end,2);


for i=1:length(countrynames)
    if countrycodes(i) == Cnum
            CountryA = string(countrynames(i));
    end
end

[numbers, TEXT, EE] = xlsread('ECDC-7Days-Testing.xlsx');

Arates = [];

for i=1:length(EE)
    if strcmp(EE(i,1), CountryA) && strcmp(EE(i,4) ,'national')
        Arates = [Arates,EE(i,11)];
    end
end

figure(25);
Arates = cell2mat(Arates);
x = (1:1:length(Arates))';
plot(x,Arates);
ylabel('Positivity Index')
xlabel('Ascending week number')
title('Positivity rate through WEEK09-2020 to WEEK53-2021')

peaks = findpeaks(Arates);
lastpeak = peaks(end);
idx = 0 ;

for i=1:length(Arates)
    if Arates(i) == lastpeak
        idx = i;
    end
end

weeks=[];
for j=1:length(EE)
    if strcmp(EE(j,1) , CountryA) && strcmp(EE(j,4) ,'national') 
        for i=1:12
            weeks = [weeks,string(EE(j+idx-12+i ,3))];
        end
        break;
    end
end

pidx = [];
new_cases = cell2mat(EE(2:end,7));
tests_done = cell2mat(EE(2:end,8));

for j=1:12 
    tot_cases = 0;
    tot_tests = 0;
    for i=1:length(EE) 
        if  strcmp(EE(i,3),weeks(j)) && strcmp(EE(i,4) , 'national') 
            tot_cases = tot_cases + new_cases(i);
            tot_tests= tot_tests + tests_done(i);             
        end    
    end
    pidx = [pidx , 100*(tot_cases/tot_tests)];
end

cases = cell2mat(greece(2:end,2));
pcrs = cell2mat(greece(2:end,46));
rapids = cell2mat(greece(2:end,45));
greek_weeks =string(greece(2:end,51));

greek_pidx=zeros(12,7);
for j=1:12 
    for i=1:length(pcrs)
        if  greek_weeks(i) == weeks(j)
            for z=0:6
                greek_pidx(j,z+1)=(cases(i)/(pcrs(i+z)-pcrs(i+z-1)+rapids(i+z)-rapids(i+z-1)))*100;
            end
            break;
        end
    end
end

grmeans = [];
for k=1:12
    greek_week = greek_pidx(k,:);
    ee_total = pidx(k);
    [value , grmean, h] = compare_pidx(greek_week,ee_total,k);
    grmeans = [grmeans,grmean];
end

figure(k+1)
clf;
y = zeros(length(grmeans),2);
y(:,1) = grmeans;
y(:,2) = pidx;
h = bar(y);
ylabel('Positivity Rate')
xlabel('Weeks of interest')
title('Graphical comparison between Greece and EU mean positivity rate')
set(h, {'DisplayName'}, {'Hellas','Europe'}')

legend()



function [diff , meangr , h] = compare_pidx( gr , ee , k)
    B = 1000;
    n = length(gr);
    means = bootstrp(B,@mean,gr);

    figure(k)
    clf
    % bins = length(last2020);
    histogram(means,10)
    xline(ee,'r');

    hold on
    ylabel('Number of Bootstrap samples means')
    xlabel('Positivity index')
    a = 34+k;
    title('Equality check between positivity Rate of Europe and Greece , Week',a);

    alpha=0.05;

    means=sort(means);
    meangr = mean(means);
    
    % means
    left_lim=round((alpha/2)*(B+1));
    right_lim=round((1-alpha/2)*(B+1));
    left=means(left_lim);
    right=means(right_lim);
    if ee>left && ee<right
        h=0
        disp('H ypothesi oti o deikths 8etikothtas ths Elladas den diaferei shmantika apo ths EE den mporei na aporrifthei ');
        diff = 0;
    elseif ee> right 
        diff = ee - right;
        h=1
        disp('H ypothesi oti o deikths 8etikothtas ths Elladas den diaferei shmantika apo ths EE aporriptetai ');
    else 
        diff = ee - left;
        h=1
        disp('H ypothesi oti o deikths 8etikothtas ths Elladas den diaferei shmantika apo ths EE aporriptetai ');
    end

end

%Arxika, me tin sinartisi findpeaks() vrikame tin teleutaia koryfwsii tou
%deikti thetikotitas stin ellada kai vrikame tin periodo endiaferontos. 
%Epeita efarmosame tin sinartisi compare_pidx() gia 12 epanalipseis gia tis
%12 sinexomenes vdomades endiaferontos , kai i ipothesi pws o deiktis
%thetikotitas tis elladas den diaferei simantika apo ton deikti tis EE tin
%analogi vdomada aporrithike 10 fores, enw gia 2 vdomades den mporei na
%aporrifthei. Ta apotelesmata epivevaiwthikan apo tin antistoixi
%istoselida, opou faientai pws o deiktis tis elladas me tin dania diaferoun
%arketa gia tis perissoteres vdomades ekeinis tis periodou.