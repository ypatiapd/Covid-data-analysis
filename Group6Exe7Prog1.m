clc;
clear;

AEM = 8606;
Cnum = mod(AEM,25) + 1;
Cnum;
[numbers, TEXT, everything] = xlsread('ECDC-7Days-Testing.xlsx');
[numbers, TEXT, countries] = xlsread('EuropeanCountries.xlsx');
length(everything);
size(everything,1);

countrycodes = cell2mat(countries(2:end,1));
countrynames = countries(2:end,2);
date = everything(2:end,3);
scale = everything(2:end,4);
positivity_idx = cell2mat(everything(2:end,11));
nations = everything(2:end,1);
[m,n] = size(date);

[numbers, TEXT, deaths_all] = xlsread('ECDC-14Days-Cases-Deaths.xlsx');
deaths_countries=deaths_all(2:end,1);
deaths_ind=deaths_all(2:end,5);
deaths_date=deaths_all(2:end,7);
deaths=cell2mat(deaths_all(2:end,6));


for i=1:length(countrynames)
    if countrycodes(i) == Cnum
            CountryA = string(countrynames(i));
    end
end

A_pos_idx_2020= zeros(20,1);
A_pos_idx_2021= zeros(20,1);
A_deaths_2020=zeros(16,1);
A_deaths_2021=zeros(16,1);

for i=1:length(scale)   
    if strcmp(nations(i), CountryA) && strcmp(scale(i,1) , 'national') && strcmp(date(i,1), '2020-W29')   
        for j=0:19
            A_pos_idx_2020(j+1,1) = positivity_idx(i+j,1);
        end
        break;
    end
    
end
for i=1:length(scale)  
    if strcmp(nations(i), CountryA) && strcmp(scale(i,1) , 'national') && strcmp(date(i,1), '2021-W29')   
        for j=0:19
            A_pos_idx_2021(j+1,1) = positivity_idx(i+j,1);
        end
        break;
    end  
end

for i=1:length(deaths_all)  
    if strcmp(deaths_countries(i) , CountryA) && strcmp(deaths_ind(i,1) ,'deaths') && strcmp( deaths_date(i,1), '2020-34')   
        for j=0:15
            A_deaths_2020(j+1,1) = deaths(i+j,1);
        end
        break;
    end  
end

for i=1:length(deaths_all)  
    if strcmp(deaths_countries(i), CountryA )&& strcmp(deaths_ind(i,1), 'deaths') && strcmp(deaths_date(i,1), '2021-34')   
        for j=0:15
            A_deaths_2021(j+1,1) = deaths(i+j,1);
        end
        break;
    end  
end

n_idx=length(A_pos_idx_2020);
n_deaths=length(A_deaths_2020);

adj_r2_2020=zeros(5,1);
adj_r2_2021=zeros(5,1);
for i=0:4
    X=A_pos_idx_2020(n_idx-n_deaths-i+1:end-i,1);
    Y=A_deaths_2020;
    m = fitlm(X,Y);
    b=table2array(m.Coefficients);
    b=b(:,1);
    k=length(b);
    figure(i+1);
    plot(m);
    title(['2020 regression model ', num2str(i+1) ,'week lag']);
    y_pred=[ones(size(X,1),1) X]*b;
    e=Y-y_pred;
    e2_linear_2020(i+1)=sum(abs(e))/n_deaths;
    se=sqrt(1/(size(X,1)-k)*(sum(e.^2)));
    r2_2020=1-sum((y_pred-Y).^2)/sum((Y-mean(Y)).^2);
    adj_r2_2020(i+1)=(1-(n_deaths-1)/(n_deaths-1-k)*sum((y_pred-Y).^2)/sum((Y-mean(Y)).^2));
    
end


for i=0:4
    X=A_pos_idx_2021(n_idx-n_deaths-i+1:end-i,1);
    Y=A_deaths_2021;
    m = fitlm(X,Y);
    b=table2array(m.Coefficients);
    b=b(:,1);
    k=length(b);
    figure(i+1);
    plot(m);
    title(['2021 regression model ', num2str(i+1) ,'week lag']);
    y_pred=[ones(size(X,1),1) X]*b;
    e=Y-y_pred;
    e2_linear_2021(i+1)=sum(abs(e))/n_deaths;
    se=sqrt(1/(size(X,1)-k)*(sum(e.^2)));
    r2_2021=1-sum((y_pred-Y).^2)/sum((Y-mean(Y)).^2);
    adj_r2_2021(i+1)=(1-(n_deaths-1)/(n_deaths-1-k)*sum((y_pred-Y).^2)/sum((Y-mean(Y)).^2));

end

x=[1 2 3 4 5];
figure(100);
plot(x,adj_r2_2021);
hold on;
scatter(x,adj_r2_2021);
hold on ;
plot(x,adj_r2_2020);
hold on;
scatter(x,adj_r2_2020);
title('adjusted r2 up to 5 weeks lag for 2020 and 2021');
legend('2021','2020');

% Paratiroume apo tis grafikes parastaseis twn modelwn provlepsis thanatwn 
% gia tis antistoixes periodous 16 evdomadwn to 2020 kai 2021 ,
% kai apo tous suntelestes prosdiorismou r2 kai adj_r2 
% pws to kalitero modelo aplis grammikis palindromisis, 
% ,einai auto me isterisi 5 vdomadwn.
% To siberasma auto isxuei kai gia tis 2 periodous.
% Apo tin grafiki parastasi twn sintelestwn adj_r2 gia 2020 kai 2021 
% paratiroume pws oso auksanetai i isterisi , o syntelestis auksanetai 
% sxedon panta grammika.

