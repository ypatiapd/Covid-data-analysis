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

int_gr_deaths_2020 = zeros(85,1);
counter = 0;

for i=1:length(gr_deaths)
    if  strcmp(greek_weeks(i) , '2020-W40')
        counter = i;
        for j=0:84
           int_gr_deaths_2020(j+1,1) = gr_deaths(i+j);
        end
        break;
    end
end

gr_pos_rat_2020 = gr_pos_rat(counter-31:counter+83,1);

int_gr_deaths_2021 = zeros(85,1);
counter = 0;

for i=1:length(gr_deaths)
    if  strcmp(greek_weeks(i) , '2021-W20')
        counter = i;
        for j=0:84
           int_gr_deaths_2021(j+1) = gr_deaths(i+j);
        end
        break;
    end
end

gr_pos_rat_2021 = gr_pos_rat(counter-31:counter+83,1);


x1 = zeros(85,30);
for j = 1 :85
    x1(j,:) = gr_pos_rat_2020(j:j+29,1);
end

x2 = zeros(85,30);
for j = 1 :85
    x2(j,:) = gr_pos_rat_2021(j:j+29,1);
end


y1 = int_gr_deaths_2020;
y2 = int_gr_deaths_2021;

n = length(int_gr_deaths_2020);

n_test=length(int_gr_deaths_2020)/5;

y_pred_total_2020 = [];
y_test_total_2020 = [];

y_pred_total_2020_step = [];
y_test_total_2020_step = [];

% First Period

for i=0:4
    X=x1;
    Y=y1;
    start=i*n_test+1;
    stop=start+n_test-1;
    X(start:stop,:)=[];
    Y(start:stop)=[];
    n=length(Y);
    m=fitlm(X,Y);
    b=table2array(m.Coefficients);
    b=b(:,1);
    k=length(b);
    
    X_test=x1(start:stop,:);
    Y_test=y1(start:stop);
  
    y_pred=[ones(size(X_test,1),1) X_test]*b;
    y_pred_total_2020 = [y_pred_total_2020 ; y_pred];
    y_test_total_2020 = [y_test_total_2020 ; Y_test];
     
    % stepwise regression for first pediod

    [b,g,t,model,stats]= stepwisefit(X,Y);
    b0=stats.intercept;
    b=[b0;b(model)];
    k=length(b);
    y_pred=[ones(size(X_test,1),1) X_test(:,model)]*b;
    y_pred_total_2020_step = [y_pred_total_2020_step ; y_pred];
    y_test_total_2020_step = [y_test_total_2020_step ; Y_test];    
    
end

%linear

n_test = length(y_test_total_2020);
e= y_test_total_2020-y_pred_total_2020;
se=sqrt(1/(size(y_test_total_2020,1)-k)*(sum(e.^2)));
r21=1-sum((y_pred_total_2020-y_test_total_2020).^2)/sum((y_test_total_2020-mean(y_test_total_2020)).^2);
adj_r21=(1-(n_test-1)/(n_test-1-k)*sum((y_pred_total_2020-y_test_total_2020).^2)/sum((y_test_total_2020-mean(y_test_total_2020)).^2));

% stepwise

e= y_test_total_2020_step-y_pred_total_2020_step;
se=sqrt(1/(size(y_test_total_2020_step,1)-k)*(sum(e.^2)));
r21_step=1-sum((y_pred_total_2020_step-y_test_total_2020_step).^2)/sum((y_test_total_2020_step-mean(y_test_total_2020_step)).^2);
adj_r21_step=(1-(n_test-1)/(n_test-1-k)*sum((y_pred_total_2020_step-y_test_total_2020_step).^2)/sum((y_test_total_2020_step-mean(y_test_total_2020_step)).^2));


%Second period

n = length(int_gr_deaths_2021);

n_test=length(int_gr_deaths_2021)/5;

y_pred_total_2021 = [];
y_test_total_2021 = [];

y_pred_total_2021_step = [];
y_test_total_2021_step = [];

for i=0:4
    X=x2;
    Y=y2;
    start=i*n_test+1;
    stop=start+n_test-1;
    X(start:stop,:)=[];
    Y(start:stop)=[];
    n=length(Y);
    m=fitlm(X,Y);
    b=table2array(m.Coefficients);
    b=b(:,1);
    k=length(b);
    
    X_test=x1(start:stop,:);
    Y_test=y1(start:stop);
  
    y_pred=[ones(size(X_test,1),1) X_test]*b;
    y_pred_total_2021 = [y_pred_total_2021 ; y_pred];
    y_test_total_2021 = [y_test_total_2021 ; Y_test];
     
    % stepwise regression for first pediod

    [b,g,t,model,stats]= stepwisefit(X,Y);
    b0=stats.intercept;
    b=[b0;b(model)];
    k=length(b);
    y_pred=[ones(size(X_test,1),1) X_test(:,model)]*b;
    y_pred_total_2021_step = [y_pred_total_2021_step ; y_pred];
    y_test_total_2021_step = [y_test_total_2021_step ; Y_test];    
    
end

%linear

n_test = length(y_test_total_2021);
e= y_test_total_2021-y_pred_total_2021;
se=sqrt(1/(size(y_test_total_2021,1)-k)*(sum(e.^2)));
r22=1-sum((y_pred_total_2021-y_test_total_2021).^2)/sum((y_test_total_2021-mean(y_test_total_2021)).^2);
adj_r22=(1-(n_test-1)/(n_test-1-k)*sum((y_pred_total_2021-y_test_total_2021).^2)/sum((y_test_total_2021-mean(y_test_total_2021)).^2));

% stepwise

e= y_test_total_2021_step-y_pred_total_2021_step;
se=sqrt(1/(size(y_test_total_2021_step,1)-k)*(sum(e.^2)));
r22_step=1-sum((y_pred_total_2021_step-y_test_total_2021_step).^2)/sum((y_test_total_2021_step-mean(y_test_total_2021_step)).^2);
adj_r22_step=(1-(n_test-1)/(n_test-1-k)*sum((y_pred_total_2021_step-y_test_total_2021_step).^2)/sum((y_test_total_2021_step-mean(y_test_total_2021_step)).^2));

fprintf('Adjusted R2 linear regression for the first period is calculated =%3.3f  \n',adj_r21);
fprintf('Adjusted R2 stepwise regression for the first period is calculated =%3.3f  \n',adj_r21_step);
 
fprintf('Adjusted R2 linear regression for the second period is calculated =%3.3f  \n',adj_r22);
fprintf('Adjusted R2 stepwise regression for the second period is calculated =%3.3f  \n',adj_r22_step);
 
% Xwrisame to training set se 5 isa merh kai efarmozontas thn diadikasia
% tou cross-validation pou perigrafetai sthn ekfwnhsh gia tis periodous
% 2020 , 2021. Sullegoume tis problepseis twn linear kai stepwise modelwn
% gia ka8e diaforetiko training set. Sth sunexeia upologizoume ton
% prosarmosmeno suntelesth prosdiorismou gia ta 2 modela , gia tis 2
% periodous. Parathroume upshles times gia linear kai stepwise modela gia
% thn periodo tou 2020. Enw , gia thn periodo tou 2021 upologizoume
% xamhloteres times pou pi8ana ofeiletai sto gegonows pws ta dedomena gia thn
% sugkekrimenh pandhmikh periodo den tairiazoun sta sugkekrimena
% grammika montela problepshs.















