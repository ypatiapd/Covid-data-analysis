clc;
clear;

AEM = 8606;
Cnum = mod(AEM,25) + 1;
Cnum;
[numbers, TEXT, everything] = xlsread('ECDC-7Days-Testing.xlsx');
[numbers, TEXT, countries] = xlsread('EuropeanCountries.xlsx');
% everything
length(everything);
size(everything,1);

countrycodes = cell2mat(countries(2:end,1));
countrynames = countries(2:end,2);
date = everything(2:end,3);
scale = everything(2:end,4);
positivity_idx = cell2mat(everything(2:end,11));
nations = everything(2:end,1);
[m,n] = size(date);

for i=1:length(countrynames)
    if countrycodes(i) == Cnum
            CountryA = string(countrynames(i));
    end
end

for z=Cnum-2:Cnum+2
    
    pos_idx_2020=zeros(9,1);
    pos_idx_2021=zeros(9,1);


    for i=1:m
        if strcmp(nations(i) , string(countrynames(z))) && strcmp(scale(i,1), 'national') && strcmp(date(i,1), '2020-W42')   
            for j=0:8
                pos_idx_2020(j+1,1) =positivity_idx(i+j,1);
            end
        end
        if strcmp(nations(i) , string(countrynames(z))) && strcmp(scale(i,1) ,'national') && strcmp(date(i,1), '2021-W42')   
            for j=0:8
                pos_idx_2021(j+1,1) =positivity_idx(i+j,1);
            end
        end
    end
    
    %%Bootstrap ci
   
    B = 100;
    [means_2020] = bootstrp(B,@mean,pos_idx_2020);
    [means_2021] = bootstrp(B,@mean,pos_idx_2021);
    idx_diff_means=means_2020-means_2021;
    zero=0;
    figure(z)
    clf
    bins = 10;
    histogram(idx_diff_means,bins);
    xline(zero,'r');% lathoooos vlepoume an periexetai to 0

    hold on

    % ax = axis;
    % plot(-tcrit*[1 1],[ax(3) ax(4)],'r')
    ylabel('Bootstrap Samples')
    xlabel('Positivity index difference')
    % rholow = length(find(tM(1,:)-tlV<0));
    title('Bootstrap ci for country', num2str(z-4))

    alpha=0.05;

    idx_diff_means=sort(idx_diff_means);

    % means
    left_lim=round((alpha/2)*(B+1));
    right_lim=round((1-alpha/2)*(B+1));
    left=idx_diff_means(left_lim);
    right=idx_diff_means(right_lim);
    if zero>left && zero<right
        h_boot=0
        a=sprintf('bootstrap:i upothesi oti den uparxoun simantikes diafores sto deikti thetikotitas 2020 kai 2021 sti xwra %d den mporei na aporrifthei ',z-4 );
        disp(a);
    else 
        h_boot=1
        a=sprintf('bootstrap:uparxoun simantikes diafores sto deikti thetikotitas 2020 kai 2021 sti xwra %d aporriptetai ',z-4 );
        disp(a);
    end
    
    %%Parametric ci 
    
    [h_param,p] = ttest(pos_idx_2020,pos_idx_2021);
    
    if h_param==1
        h_param
        a=sprintf('parametric:i ipothesi oti o deiktis thetikotitas tou 2020 kai 2021 den exei diafora stin xwra %d aporriptetai',z-4);
        disp(a);
    else
        h_param
        a=sprintf('parametric:i ipothesi oti o deiktis thetikotitas tou 2020 kai 2021 den exei diafora stin xwra %d den mporei na aporrifthei',z-4);
        disp(a);
    end
    
end

%Me tin efarmogi bootstrap kai parametrikou elegxou paratisoume oti uparxei
%simfwnia twn 2 elegxwn se 4 apo tis 5 sigriseis meswn timwn twn xwrwn. 
%Mporoume na apodosoume tin mia asimfonia sto oti o parametrikos elegxos meso
%tis ttest ginetai upothetontas kanoniki katanomi, enw emeis exoume agnwsti
%katanomi, kai mikro arithmo deigmatos n .
%En prokeimeno o bootstrap elegxos eina kai o pio aksiopistos
