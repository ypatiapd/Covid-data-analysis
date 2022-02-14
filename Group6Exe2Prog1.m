clc;
clear;
 
[numbers, TEXT, everything] = xlsread('ECDC-7Days-Testing.xlsx');
length(everything);
size(everything,1);

date = everything(2:end,3);
scale = everything(2:end,4);
positivity_idx = cell2mat(everything(2:end,11));
country = everything(2:end,1);
[m,n] = size(date);
last2020 = [];
countries2020 = [];
countries2021 = [];
last2021 = [];


for i = 1:m
    if strcmp(date(i) , '2020-W50') && strcmp(scale(i) , 'national')
        last2020 = [last2020,positivity_idx(i)];
        countries2020 = [countries2020,country(i)];
    end
    if strcmp(date(i) , '2021-W50') && strcmp(scale(i) ,'national')
        if ismember(country(i),countries2020)  %use d(:,1) to check only first column

            last2021 = [last2021,positivity_idx(i)];
            countries2021 = [countries2021,country(i)];


        else
            continue;
        end
    end   
end


h = kstest2(last2020,last2021) 

n=length(last2020);
samples_2020=zeros(length(last2020),2);
samples_2021=zeros(length(last2021),2);

samples_2020(:,1)=last2020;
samples_2021(:,1)=last2021;
samples_2020(:,1)=sort(samples_2020(:,1));
samples_2021(:,1)=sort(samples_2021(:,1));
samples_2020(:,2)=(1:1:n)/n;
samples_2021(:,2)=(1:1:n)/n;

B=100;
smirnov=zeros(n,1);
kolmogorov=zeros(B+1,1);
for i =1:n
    freq=(n-sum(samples_2020(i,1)<samples_2021(:,1)))/n;
    smirnov(i)=abs(samples_2020(i,2)-freq);
end
kolmogorov(1)=max(smirnov);

pool=[samples_2020(:,1); samples_2021(:,1)];

pool=pool((randperm(2*n)));
for i=1:B
    X=zeros(n,2);
    mixed_samples=pool(randperm(2*n));
    X(:,1)=mixed_samples(1:27);
    Y=mixed_samples(28:end);
    X(:,1)=sort(X(:,1));
    X(:,2)=(1:1:n)/n;
    for j =1:n
        freq=(n-sum(X(j,1)<Y))/n;
        smirnov(j)=abs(X(j,2)-freq);
    end
    kolmogorov(i+1)=max(smirnov);
end

sample_stat=kolmogorov(1);
figure(1)
clf
bins = 8;
histogram(kolmogorov);
xline(sample_stat,'r');
hold on
ylabel('Frequency')
xlabel('Kolmogorov statistic')
title('Kolmogorov-Smirnov bootstrap samples empirical distribution')
disp('done')

alpha=0.05;

kolmogorov=sort(kolmogorov);
left_lim=round((alpha/2)*(B+1));
right_lim=round((1-alpha/2)*(B+1));
left=kolmogorov(left_lim);
right=kolmogorov(right_lim);

if sample_stat>left && sample_stat<right
   disp('H ipothesi oti oi katanomes tou deikti thetikotitas den diaferoun den mporei na aporrifthei'); 
end


%Oi katanomes tou deikti thetikotitas den diaferoun,me sigouria 95%
%kathws i timi tou statistikou gia to arxiko deigma, vrisketai entos
%tou diastimatos empistosinis pou proekipse apo B bootstrap deigmata
%tyxaias antimetathesis. Xrhsimopoioume thn sunarthsh tou matlab 
% kstest2 gia epalh8eush twn sumperasmatwn mas , pws me ton upologismo tou 
% statistikou Kolmogorov-Smirnov oi duo katanomes den diaferoun se epipedo 
% empistosunhs 95%.


