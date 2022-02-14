clc;
clear;

AEM = 8606;
Cnum = mod(AEM,25) + 1;
Cnum;
[numbers, TEXT, everything] = xlsread('ECDC-7Days-Testing.xlsx');
[numbers, TEXT, countries] = xlsread('EuropeanCountries.xlsx');
[numbers, TEXT, greece] = xlsread('FullEodyData.xlsx');

gr_deaths = cell2mat(greece(2:end,5));
gr_deaths(isnan(gr_deaths))=0;
gr_cases = cell2mat(greece(2:end,2));
gr_pcrs = cell2mat(greece(2:end,45));

greek_weeks =string(greece(2:end,51));
gr_rapids = cell2mat(greece(2:end,46));
gr_rapids(isnan(gr_rapids))=0;

gr_pos_rat = zeros(length(gr_rapids)-1,1);
for i=2:length(gr_cases)
   if (gr_pcrs(i) + gr_rapids(i) - gr_pcrs(i-1) - gr_rapids(i-1)) > 0
        gr_pos_rat(i-1,1) = (gr_cases(i) / (gr_pcrs(i) + gr_rapids(i) - gr_pcrs(i-1) - gr_rapids(i-1))) * 100;
   else
        gr_pos_rat(i-1,1) = gr_pos_rat(i-2,1);
   end
end

int_gr_deaths_2020 = zeros(84,1);
counter = 0;

for i=1:length(gr_deaths)
    if strcmp( greek_weeks(i) , '2020-W40')
        counter = i;
        for j=0:83
           int_gr_deaths_2020(j+1,1) = gr_deaths(i+j);
        end
        break;
    end
end

gr_pos_rat_2020 = gr_pos_rat(counter-31:counter+82,1);
int_gr_deaths_2021 = zeros(84,1);
counter = 0;

for i=1:length(gr_deaths)
    if  strcmp(greek_weeks(i) , '2021-W20')
        counter = i;
        for j=0:83
           int_gr_deaths_2021(j+1) = gr_deaths(i+j);
        end
        break;
    end
end

gr_pos_rat_2021 = gr_pos_rat(counter-31:counter+82,1);


x1 = zeros(84,30);
for j = 1 :84
    x1(j,:) = gr_pos_rat_2020(j:j+29,1);
end

x2 = zeros(84,30);
for j = 1 :84
    x2(j,:) = gr_pos_rat_2021(j:j+29,1);
end


y1 = int_gr_deaths_2020;
y2 = int_gr_deaths_2021;

n = length(int_gr_deaths_2020);

% simple linear regression first pediod
n=length(y1);

m=fitlm(x1,y1);
b=table2array(m.Coefficients);
b=b(:,1);
k=length(b);

y_pred=[ones(length(x1),1) x1]*b;
e=y1-y_pred;
se=sqrt(1/(length(x1)-k)*(sum(e.^2)));
r2=1-sum((y_pred-y1).^2)/sum((y1-mean(y1)).^2);
adj_r21=(1-(n-1)/(n-1-k)*sum((y_pred-y1).^2)/sum((y1-mean(y1)).^2));

% stepwise regression for first pediod

[b,g,t,model,stats]= stepwisefit(x1,y1);
b0=stats.intercept;
b=[b0;b(model)];
k=length(b);
y_pred=[ones(length(x1),1) x1(:,model)]*b;
e_step=y1-y_pred;
se_step=sqrt(1/(length(x1)-k)*(sum(e_step.^2)));
r2_step=1-stats.SSresid/stats.SStotal;
adj_r21_step=(1-(n-1)/(n-1-k)*sum((y_pred-y1).^2)/sum((y1-mean(y1)).^2));

% simple linear regression second pediod

n=length(y2);

m=fitlm(x2,y2);
b=table2array(m.Coefficients);
b=b(:,1);
k=length(b);

y_pred=[ones(length(x2),1) x2]*b;
e=y2-y_pred;

se=sqrt(1/(length(x2)-k)*(sum(e.^2)));
r2=1-sum((y_pred-y2).^2)/sum((y2-mean(y2)).^2);
adj_r22=(1-(n-1)/(n-1-k)*sum((y_pred-y2).^2)/sum((y2-mean(y2)).^2));

% stepwise regression for second pediod
[b,g,t,model,stats]= stepwisefit(x2,y2);
b0=stats.intercept;
b=[b0;b(model)];
k=length(b);
y_pred=[ones(length(x2),1) x2(:,model)]*b;
e_step=y2-y_pred;
se_step=sqrt(1/(length(x2)-k)*(sum(e_step.^2)));
r2_step=1-stats.SSresid/stats.SStotal;
adj_r22_step=(1-(n-1)/(n-1-k)*sum((y_pred-y2).^2)/sum((y2-mean(y2)).^2));


fprintf('adjusted r2 linear regression for the first period is calculated =%3.3f  \n',adj_r21);
fprintf('adjusted r2 stepwise regression for the first period is calculated =%3.3f  \n',adj_r21_step);

fprintf('adjusted r2 linear regression for the second period is calculated =%3.3f  \n',adj_r22);
fprintf('adjusted r2 stepwise regression for the second period is calculated =%3.3f  \n',adj_r22_step);



% Dhmiourghsame ston pinaka x , 30 sthles gia tous 30 deiktes ka8hmerinhs
% 8etikothtas pou antistoixoun stis 30 meres pou prohgountai ka8e mias apo tis 84 (grammes) meres ka8e periodou twn
% opoiwn tous hmerisous 8anatous 8eloume na problepsoume.
% Parathroume oti ta duo stepwise montela dialegoun diaforetiko sunduasmo hmerwn gia na 
% provlepsoun kata veltisto tropo tous hmerisous 8anatous mesw ths bhmatikhs 
% epiloghs metablhtwn. Parallhla kai ta duo linear montela pou den meiwnoume tis
% diastaseis tous , estw kai gia ligo upoleipontai twn stepwise montelwn
% sumfwna me ton prosarmosmeno suntelesth prosdiorismou.