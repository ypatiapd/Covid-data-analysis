clc;
clear;

[numbers, TEXT, greece] = xlsread('FullEodyData.xlsx');

% g daily tubed
% G DAILY TUBED
% h daily unvax 
% B NEW CASES 
% O P Q , cases-deaths-tubed 40-64
% R S T , -"- 64<
% BA , ICU exits
% BB , hospitalization bc exits

daily_tubed_unvaxed = cell2mat(greece(2:end,8));
cases_64 = cell2mat(greece(2:end,18));
cases_40 =  cell2mat(greece(2:end,15));

gr_deaths = cell2mat(greece(2:end,5));
gr_deaths(isnan(gr_deaths))=0;

gr_cases = cell2mat(greece(2:end,2));
gr_pcrs = cell2mat(greece(2:end,45));

greek_weeks =string(greece(2:end,51));
gr_rapids = cell2mat(greece(2:end,46));
gr_rapids(isnan(gr_rapids))=0;

pos_rat = zeros(length(gr_rapids)-1,1);
for i=2:length(cases_64)
   if (gr_pcrs(i) + gr_rapids(i) - gr_pcrs(i-1) - gr_rapids(i-1)) > 0
        pos_rat(i-1,1) = (gr_cases(i) / (gr_pcrs(i) + gr_rapids(i) - gr_pcrs(i-1) - gr_rapids(i-1))) * 100;
   else
        pos_rat(i-1,1) = pos_rat(i-2,1);
   end
end

daily_cases_40 = zeros(length(cases_40),1);
daily_cases_64 = zeros(length(cases_64),1);

for i=2:length(gr_cases)
    daily_cases_64(i) = cases_64(i) - cases_64(i-1);
    daily_cases_40(i) = cases_40(i) - cases_40(i-1);
end

int_gr_deaths = zeros(105,1);
counter = 0;

for i=1:length(gr_deaths)
    if  strcmp(greek_weeks(i) , '2021-W37')
        counter = i;
        for j=0:104
           int_gr_deaths(j+1,1) = gr_deaths(i+j);
           
        end
        break;
    end
end

int_pos_rat = pos_rat(counter-14:counter+104,1);

int_daily_cases_64 = daily_cases_64(counter-14:counter+104,1);

int_daily_cases_40= daily_cases_40(counter-14:counter+104,1);

int_daily_tubed = daily_tubed_unvaxed(counter-14:counter+104,1);

x_tubed = zeros(105,14);
x_pos_rat = zeros(105,14);
x_cases_64 = zeros(105,14);
x_cases_40 = zeros(105,14);

for j = 1 :105
    x_cases_64(j,:) = int_daily_cases_64(j:j+13,1);
    x_cases_40(j,:) = int_daily_cases_40(j:j+13,1);
    x_tubed(j,:) = int_daily_tubed(j:j+13,1);
    x_pos_rat(j,:) = int_pos_rat(j:j+13,1);

end

y1 = int_gr_deaths; 
n = length(int_gr_deaths);

%%%%%%%%%%%%%%%%%%

[b,g,t,model,stats]= stepwisefit(x_tubed,y1);

total = [x_tubed(:,model)];

[b,g,t,model,stats]= stepwisefit(x_cases_64,y1);

total = [total x_cases_64(:,model)];

% [b,g,t,model,stats]= stepwisefit(x_cases_40,y1);
% total = [total x_cases_40(:,model)]; 
% [b,g,t,model,stats]= stepwisefit(x_pos_rat,y1);
% total = [total x_pos_rat(:,model)];

[b,g,t,model,stats]= stepwisefit(total,y1);

n=length(y1);
m=fitlm(total,y1);
b=table2array(m.Coefficients);
b=b(:,1);
k=length(b);
y_pred=[ones(length(total),1) total]*b;
e=y1-y_pred;
se=sqrt(1/(length(total)-k)*(sum(e.^2)));
r2=1-sum((y_pred-y1).^2)/sum((y1-mean(y1)).^2)
adj_r22=(1-(n-1)/(n-1-k)*sum((y_pred-y1).^2)/sum((y1-mean(y1)).^2))

%Epileksame tous deiktes diaswlinwmenwn, krousmata anw twn 40, krousmata
%anw twn 64 kai ton deikti thetikotitas. Epeita, gia ta dedomena kathe
%deikti efarmosame stepwise regression, gia na ginei i epilogi twn stilwn
%pou aforoun tin xroniki usterisi ews kai 30 meres prin . Sti sinexeia, enwsame
%tis epilegmenes stiles apo kathe deikti , kai trofodotisame me ta sinolika
%dedomena ena neo montelo stepwise regression. Paratirisame oti to montelo
%epilegei stiles pou aforoun mono ta krousata anw twn 64 kai tous
%diaswlinwmenous, epomenws epileksame autous tous 2 deiktes gia to teliko
%montelo provlepsis mas, to opoio xrisimopoiei sinolika 3 stiles, mia apo
%ton deikti diaswlinomenwn (1 mera usterisi), kai 2 apo ton deikti 
%krousmatwn anw twn 64(12 kai 10 meres usterisi).


