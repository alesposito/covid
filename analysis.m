%% Load data
clear all
close all

% https://github.com/CSSEGISandData/COVID-19
folder = 'C:\Users\ae275\Desktop\COVID-19-master\csse_covid_19_data\csse_covid_19_time_series\';
con_file = 'time_series_covid19_confirmed_global.csv';
dea_file = 'time_series_covid19_deaths_global.csv';

con = readtable([folder con_file],'readvariablenames',true);
dea = readtable([folder dea_file],'readvariablenames',true);

nn = height(con);
nt = width(con)-4;


%% Process China (Hubei / China / China-Hubei)
% find China entries
idxChina = find(ismember(table2array(dea(:,2)),'China'));
idxHubei = find(ismember(table2array(dea(:,1)),'Hubei'));

deaChina = table2array(dea(idxChina,5:nt+4));
conChina = table2array(con(idxChina,5:nt+4));
deaHubei = table2array(dea(idxHubei,5:nt+4));
conHubei = table2array(con(idxHubei,5:nt+4));
 
dea(height(dea)+1,2)   = cell2table({'ChinaAll'});
dea(height(dea),5:end) = array2table(sum(deaChina));
con(height(con)+1,2)   = cell2table({'ChinaAll'});
con(height(con),5:end) = array2table(sum(conChina));
 
dea(height(dea)+1,2)   = cell2table({'RestChina'});
dea(height(dea),5:end) = array2table(sum(deaChina)-deaHubei);
con(height(con)+1,2)   = cell2table({'RestChina'});
con(height(con),5:end) = array2table(sum(conChina)-conHubei);

nn = height(con);

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
[madj_usa_b madj_usa_w] = madj(folder,'USA-2019.csv',mortality_else,mortality_hubei);



%% Analysis (Input)
close all

synch_type = 1; % 0: none; 1: deaths; 2: confirmed cases
countries = {'Italy','United Kingdom','Hubei','Spain','France','US','Germany','Denmark','Sweden','Turkey','Iran','Belgium','Netherlands','Switzerland','Austria','Singapore','Korea, South','Russia','Japan','ChinaAll','RestChina'}; % List of countries to check
synch_num = 40; % Synch all curves at this level of confirmed cases
col = 'gbrmkkkkkk' % Color series to use for display

% Italy and Hubei are used as reference cases, the following are indexes to
% countries we want to compare with these references
%idx_countries =(1:length(countries));
idx_countries = 21;

xpad = 30;
% init
ns = 3;
nc = length(countries);


% search data
idx = ones([nc 1]);
for ic=1:nc
    tmp_idx = find(strcmp(con.Country_Region,countries{ic}));
    
    switch length(tmp_idx)
        case 1 % unique country name identified
            idx(ic)=tmp_idx;
        case 0 % probably not a country, scan region
            idx(ic) = find(strcmp(con.Province_State,countries{ic}));
        otherwise % probably multiple territories, identify country
            idx(ic) = tmp_idx(find(strcmp(con.Province_State(tmp_idx),'')));        
    end
end
clear tmp_idx

cona = table2array(con(idx,5:nt+4)); % confirmed cases
deaa = table2array(dea(idx,5:nt+4)); % deaths
day  = (1:nt);


dayabs = con.Properties.VariableNames(5:end);
day_hubei = 'x1_23_20'
day_italy = 'x3_9_20'
day_italy0 = 'x2_22_20'
day_uk0 = 'x3_12_20';
day_uk = 'x3_24_20';


% synch data
day0_=[];
for ic=1:nc   
    
    % synch index
    switch synch_type
        case 0 % no synching
            day0 = 1;
            xpad = 1;
        case 1 % synch deaths
            day0 = min(find(deaa(ic,:)>synch_num));
        case 2 % synch cases
            day0 = min(find(cona(ic,:)>synch_num));
    end
    
    last_weak = log10(cona(ic,nt-6:nt));
    secondlast_weak = log10(cona(ic,nt-13:nt-7));
    
        if isempty(day0)
        day0=0;
    end
    
    tmp = circshift([cona(ic,:) zeros([1 xpad])],-day0+xpad);
    cona(ic,:) = tmp(1:nt);
    tmp = circshift([deaa(ic,:) zeros([1 xpad])],-day0+xpad);
    deaa(ic,:) = tmp(1:nt);

    day0_(ic) = day0;
        switch countries{ic}
            case 'Hubei'
                hubei_mark = -day0+xpad+find(strcmp(dayabs,day_hubei));
            case 'Italy'
                italy_mark = -day0+xpad+find(strcmp(dayabs,day_italy));
                italy_mark0 = -day0+xpad+find(strcmp(dayabs,day_italy0));
            case 'United Kingdom'
                uk_mark = -day0+xpad+find(strcmp(dayabs,day_uk));
                uk_mark0 = -day0+xpad+find(strcmp(dayabs,day_uk0));
        end
    
end

% apparent mortality
mora = (deaa./cona);

% display
for iv=1:length(idx_countries)
    id_show = [1 idx_countries(iv) 3]; 

    hf=figure;
    set(hf,'Units','normalized','position',[0.3127 0.40 0.3733 0.500])

    synch_lbl =['synch (' num2str(synch_num) ')']

    subplot(3,1,1)
    hold all
    for ic=1:ns
        plot(day,cona(id_show(ic),:),col(ic))
       % plot(day0_(ic),cona(id_show(ic),day0_(ic)),['O' col(ic)])
        if synch_type==2
            plot(day0_(ic),2*max(cona(:)),['O' col(ic)])
        end
    end
    set(gca,'yscale','log','xlim',[1 nt])
    xlabel('relative time (day)')
    ylabel('confirmed cases')
    plot([hubei_mark hubei_mark], get(gca,'ylim'),'--r')
    plot([italy_mark italy_mark], get(gca,'ylim'),'-.g')
    plot([italy_mark0 italy_mark0], get(gca,'ylim'),'-.g')
    plot([uk_mark uk_mark], get(gca,'ylim'),'-.b')
    plot([uk_mark0 uk_mark0], get(gca,'ylim'),'-.b')
    box on
    if synch_type==2
        legend(cat(2,countries(id_show(1)),synch_lbl,countries(id_show(2)),synch_lbl,countries(id_show(3)),synch_lbl,'Hubei lockdown','Italy national lockdown','Italy local lockdown','UK in lockdown','UK switches to mitigation'),'location','eastoutside')
    else
        legend(cat(2,countries(id_show),'Hubei lockdown','Italy national lockdown','Italy local lockdown','UK in lockdown','UK switches to mitigation'),'location','eastoutside')
    end




    subplot(3,1,2)
    hold all
    for ic=1:ns
        plot(day,deaa(id_show(ic),:),col(ic))
        if synch_type==1
            plot(day0_(ic),2*max(deaa(:)),['O' col(ic)])
        end
    end
    set(gca,'yscale','log','xlim',[1 nt])
    box on
    xlabel('relative time (day)')
    ylabel('deaths')
    plot([hubei_mark hubei_mark], get(gca,'ylim'),'--r')
    plot([italy_mark italy_mark], get(gca,'ylim'),'-.g')
    plot([italy_mark0 italy_mark0], get(gca,'ylim'),'-.g')
    plot([uk_mark uk_mark], get(gca,'ylim'),'-.b')
    plot([uk_mark0 uk_mark0], get(gca,'ylim'),'-.b')
    box on
    if synch_type==1
        legend(cat(2,countries(id_show(1)),synch_lbl,countries(id_show(2)),synch_lbl,countries(id_show(3)),synch_lbl,'Hubei lockdown','Italy national lockdown','Italy local lockdown','UK in lockdown','UK switches to mitigation'),'location','eastoutside')
    else
        legend(cat(2,countries(id_show),'Hubei lockdown','Italy national lockdown','Italy local lockdown','UK in lockdown','UK switches to mitigation'),'location','eastoutside')
    end

    subplot(3,1,3)
    hold all
    for ic=1:ns
        plot(day,mora(id_show(ic),:),col(ic))
    end
    set(gca,'yscale','log','xlim',[1 nt])
    box on
    xlabel('relative time (day)')
    ylabel('apparent mortality')
    plot([hubei_mark hubei_mark], get(gca,'ylim'),'--r')
    plot([italy_mark italy_mark], get(gca,'ylim'),'-.g')
    plot([italy_mark0 italy_mark0], get(gca,'ylim'),'-.g')
    plot([uk_mark uk_mark], get(gca,'ylim'),'-.b')
    plot([uk_mark0 uk_mark0], get(gca,'ylim'),'-.b')
    box on
   legend(cat(2,countries(id_show),'Hubei lockdown','Italy national lockdown','Italy local lockdown','UK in lockdown','UK switches to mitigation'),'location','eastoutside')
    saveas(hf,[num2str(synch_type) countries{id_show(2)} '.png'])
    %close(hf)
end
    
    
    
    
%% Plot mortality rates - still to be generalized - edit manually)
nnc = 8;
mmax = 0.12;

figure
subplot(nnc,1,1)
title('Italy')
hold all
plot(day,mora(find(strcmp(countries,'Italy')),:),'k')
plot([1 day(end)],[madj_italy_b madj_italy_b],'b')
plot([1 day(end)],[madj_italy_w madj_italy_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 mmax])
box on
xlabel('day')
ylabel('mortality rate')

subplot(nnc,1,2)
title('UK')
hold all
plot(day,mora(find(strcmp(countries,'United Kingdom')),:),'k')
plot([1 day(end)],[madj_uk_b madj_uk_b],'b')
plot([1 day(end)],[madj_uk_w madj_uk_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 mmax])
box on
xlabel('day')
ylabel('mortality rate')

subplot(nnc,1,3)
title('Hubei')
hold all
plot(day,mora(find(strcmp(countries,'Hubei')),:),'k')
plot([1 day(end)],[madj_china_b madj_china_b],'b')
plot([1 day(end)],[madj_china_w madj_china_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 mmax])
box on
xlabel('day')
ylabel('mortality rate')


subplot(nnc,1,4)
title('South Korea')
hold all
plot(day,mora(find(strcmp(countries,'Korea, South')),:),'k')
plot([1 day(end)],[madj_korea_b madj_korea_b],'b')
plot([1 day(end)],[madj_korea_w madj_korea_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 mmax])
box on
xlabel('day')
ylabel('mortality rate')


subplot(nnc,1,5)
title('Spain')
hold all
plot(day,mora(find(strcmp(countries,'Spain')),:),'k')
plot([1 day(end)],[madj_spain_b madj_spain_b],'b')
plot([1 day(end)],[madj_spain_w madj_spain_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 mmax])
box on
xlabel('day')
ylabel('mortality rate')


subplot(nnc,1,6)
title('France')
hold all
plot(day,mora(find(strcmp(countries,'France')),:),'k')
plot([1 day(end)],[madj_france_b madj_france_b],'b')
plot([1 day(end)],[madj_france_w madj_france_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 mmax])
box on
xlabel('day')
ylabel('mortality rate')




subplot(nnc,1,7)
title('Germany')
hold all
plot(day,mora(find(strcmp(countries,'Germany')),:),'k')
plot([1 day(end)],[madj_germany_b madj_germany_b],'b')
plot([1 day(end)],[madj_germany_w madj_germany_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 mmax])
box on
xlabel('day')
ylabel('mortality rate')


subplot(nnc,1,8)
title('USA')
hold all
plot(day,mora(find(strcmp(countries,'US')),:),'k')
plot([1 day(end)],[madj_usa_b madj_usa_b],'b')
plot([1 day(end)],[madj_usa_w madj_usa_w],'r')
set(gca,'yscale','lin','xlim',[1 nt],'ylim',[0 mmax])
box on
xlabel('day')
ylabel('mortality rate')



%% compare population pyramids... vs China

pp_china = readtable([folder '../../China-2019.csv']);
pp_italy = readtable([folder '../../Italy-2019.csv']);
pp_germany = readtable([folder '../../Germany-2019.csv']);
pp_uk = readtable([folder '../../United Kingdom-2019.csv']);

aa=pp_china.Age;
pp_china_m = pp_china.M./sum(pp_china.M+pp_china.F)
pp_china_f = pp_china.F./sum(pp_china.M+pp_china.F)
pp_italy_m = pp_italy.M./sum(pp_italy.M+pp_italy.F)
pp_italy_f = pp_italy.F./sum(pp_italy.M+pp_italy.F)
pp_germany_m = pp_germany.M./sum(pp_germany.M+pp_germany.F)
pp_germany_f = pp_germany.F./sum(pp_germany.M+pp_germany.F)
pp_uk_m = pp_uk.M./sum(pp_uk.M+pp_uk.F)
pp_uk_f = pp_uk.F./sum(pp_uk.M+pp_uk.F)


figure
subplot(3,1,1)
hold on
plot(pp_italy_m./pp_china_m,'b')
plot(pp_italy_f./pp_china_f,'r')
plot([1 21],[1 1],'k')
set(gca,'xticklabel',aa,'xtick',(1:length(aa)),'xlim',[1 21],'ylim',[0 10])
xtickangle(gca,90)
xlabel('Age')
title('Italy/China')
box on
ylabel('fold')
legend({'males','females'},'location','northwest')


subplot(3,1,2)
hold on
plot(pp_germany_m./pp_china_m,'b')
plot(pp_germany_f./pp_china_f,'r')
plot([1 21],[1 1],'k')
set(gca,'xticklabel',aa,'xtick',(1:length(aa)),'xlim',[1 21],'ylim',[0 10])
xtickangle(gca,90)
xlabel('Age')
title('Germany/China')
box on
ylabel('fold')
legend({'males','females'},'location','northwest')

subplot(3,1,3)
hold on
plot(pp_uk_m./pp_china_m,'b')
plot(pp_uk_f./pp_china_f,'r')
plot([1 21],[1 1],'k')
set(gca,'xticklabel',aa,'xtick',(1:length(aa)),'xlim',[1 21],'ylim',[0 10])
xtickangle(gca,90)
xlabel('Age')
title('UK/China')
box on
ylabel('fold')
legend({'males','females'},'location','northwest')


%%
madj_best = [madj_china_b madj_italy_b madj_uk_b madj_korea_b madj_spain_b madj_france_b madj_germany_b madj_usa_b];
madj_worst = [madj_china_w madj_italy_w madj_uk_w madj_korea_w madj_spain_w madj_france_w madj_germany_w madj_usa_w];
figure
bar([madj_best;madj_worst]')
set(gca,'xticklabel',{'China','Italy','UK','Korea','Spain','France','Germany','USA'})
ylabel('mortality')
title('Age-adjusted mortality')
legend({'best case (modelled as China outside Hubei','worst case (modelled as Hubei)'},'location','southoutside')


%%




