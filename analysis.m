%% Load data

% https://github.com/CSSEGISandData/COVID-19
folder = 'C:\Users\ae275\Desktop\COVID-19-master\csse_covid_19_data\csse_covid_19_time_series\';
con_file = 'time_series_19-covid-Confirmed.csv';
dea_file = 'time_series_19-covid-Deaths.csv';

con = readtable([folder con_file],'readvariablenames',true);
dea = readtable([folder dea_file],'readvariablenames',true);

%% initialize age-dependent mortality
%inferred from %https://www.medrxiv.org/content/10.1101/2020.02.25.20027672v2.full.pdf
age             = [ 0     10    20  30    40   50  60   70   80];
mortality_hubei = [ .002 .002 .002  .01  .02  .04  .11  .26 .49];
mortality_else  = [ .001 .001 .001  .002 .005  .01 .025 .06  .13];


%download population data from 
%https://www.populationpyramid.net/
[madj_china_b madj_china_w] = madj(folder,'China-2019.csv',mortality_else,mortality_hubei);
[madj_italy_b madj_italy_w] = madj(folder,'Italy-2019.csv',mortality_else,mortality_hubei);
[madj_uk_b madj_uk_w] = madj(folder,'United Kingdom-2019.csv',mortality_else,mortality_hubei);
[madj_korea_b madj_korea_w] = madj(folder,'Republic of Korea-2019.csv',mortality_else,mortality_hubei);
[madj_spain_b madj_spain_w] = madj(folder,'Spain-2019.csv',mortality_else,mortality_hubei);
[madj_france_b madj_france_w] = madj(folder,'France-2019.csv',mortality_else,mortality_hubei);
[madj_germany_b madj_germany_w] = madj(folder,'Germany-2019.csv',mortality_else,mortality_hubei);



%% Analysis (Input)

countries = {'Italy','United Kingdom','Hubei','Korea, South','Spain','France','Germany'}; % List of countries to check
synch_num = 400; % Synch all curves at this level of confirmed cases
col = 'gbrmkkkkkk' % Color series to use for display
id_show = [1 7 3]; % For tidyness, plot only these countries

% init
ns = length(id_show);
nc = length(countries);
nn = height(con);
nt = width(con)-4;

% search data
idx = ones([nc 1]);
for ic=1:nc
    tmp = find(strcmp(con.Country_Region,countries{ic}));
    
    switch length(tmp)
        case 1
            idx(ic)=tmp;
        otherwise
            idx(ic) = find(strcmp(con.Province_State,countries{ic}));        
    end
end

cona = table2array(con(idx,5:nt+4)); % confirmed cases
deaa = table2array(dea(idx,5:nt+4)); % deaths
day  = (1:nt);

% synch data
xpad = 20;
for ic=1:nc
    day0 = min(find(cona(ic,:)>synch_num));
    tmp = circshift([cona(ic,:) zeros([1 xpad])],-day0+xpad);
    cona(ic,:) = tmp(1:nt);
    tmp = circshift([deaa(ic,:) zeros([1 xpad])],-day0+xpad);
    deaa(ic,:) = tmp(1:nt);
end

% apparent mortality
mora = (deaa./cona);

figure
subplot(3,1,1)
hold all
for ic=1:ns
    plot(day,cona(id_show(ic),:),col(ic))
end
set(gca,'yscale','log')
xlabel('relative time (day)')
ylabel('confirmed cases')
box on
legend(countries(id_show),'location','eastoutside')

subplot(3,1,2)
hold all
for ic=1:ns
    plot(day,deaa(id_show(ic),:),col(ic))
end
set(gca,'yscale','log','xlim',[1 nt])
box on
xlabel('relative time (day)')
ylabel('deaths')
legend(countries(id_show),'location','eastoutside')


subplot(3,1,3)
hold all
for ic=1:ns
    plot(day,mora(id_show(ic),:),col(ic))
end
set(gca,'yscale','log','xlim',[1 nt])
box on
xlabel('relative time (day)')
ylabel('apparent mortality')
legend(countries(id_show),'location','eastoutside')

%% Plot mortality rates - still to be generalized 
nnc = 7;
figure
subplot(nnc,1,1)
title('Italy')
hold all
plot(day,mora(1,:),'k')
plot([1 day(end)],[madj_italy_b madj_italy_b],'b')
plot([1 day(end)],[madj_italy_w madj_italy_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 .1])
box on
xlabel('day')
ylabel('mortality rate')

subplot(nnc,1,2)
title('UK')
hold all
plot(day,mora(2,:),'k')
plot([1 day(end)],[madj_uk_b madj_uk_b],'b')
plot([1 day(end)],[madj_uk_w madj_uk_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 .1])
box on
xlabel('day')
ylabel('mortality rate')

subplot(nnc,1,3)
title('Hubei')
hold all
plot(day,mora(3,:),'k')
plot([1 day(end)],[madj_china_b madj_china_b],'b')
plot([1 day(end)],[madj_china_w madj_china_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 .1])
box on
xlabel('day')
ylabel('mortality rate')


subplot(nnc,1,4)
title('South Korea')
hold all
plot(day,mora(4,:),'k')
plot([1 day(end)],[madj_korea_b madj_korea_b],'b')
plot([1 day(end)],[madj_korea_w madj_korea_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 .1])
box on
xlabel('day')
ylabel('mortality rate')



subplot(nnc,1,5)
title('Spain')
hold all
plot(day,mora(5,:),'k')
plot([1 day(end)],[madj_spain_b madj_spain_b],'b')
plot([1 day(end)],[madj_spain_w madj_spain_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 .1])
box on
xlabel('day')
ylabel('mortality rate')


subplot(nnc,1,6)
title('France')
hold all
plot(day,mora(6,:),'k')
plot([1 day(end)],[madj_france_b madj_france_b],'b')
plot([1 day(end)],[madj_france_w madj_france_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 .1])
box on
xlabel('day')
ylabel('mortality rate')




subplot(nnc,1,7)
title('Germany')
hold all
plot(day,mora(5,:),'k')
plot([1 day(end)],[madj_germany_b madj_germany_b],'b')
plot([1 day(end)],[madj_germany_w madj_germany_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 .1])
box on
xlabel('day')
ylabel('mortality rate')






