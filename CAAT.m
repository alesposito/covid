% A. Esposito

%% COVID - age adjusted trends (CAAT 4.4)

% LIST OF PLOTS
   
plot_countries{1} =  {'Italy','United Kingdom','Hubei','ChinaAll','US','Iran'};
plot_countries{2} =  {'Italy','United Kingdom','Germany','France','Spain'};
plot_countries{3} =  {'Italy','Sweden','Denmark','Norway','Finland'};
plot_countries{4} =  {'Italy','Netherlands','Belgium','France'};
plot_countries{5} =  {'Italy','Netherlands','Germany','Austria','Switzerland'};
plot_countries{6} =  {'Italy','Japan','Hubei','ChinaAll','Republic of Korea','Singapore'};
plot_countries{7} =  {'Italy','Hubei','Ireland','United Kingdom','Iceland'};
plot_countries{8} =  {'Italy','Hubei','US','Russia','Turkey','United Kingdom'};
plot_countries{9} =  {'US','Brazil','Argentina','Mexico','Canada','Peru','Chile'};
plot_countries{10} =  {'Italy','Bulgaria','Romania','Greece','Hungary','Poland'};
plot_countries{11} =  {'Italy','United Kingdom','Germany','Denmark','Sweden'};
plot_countries{12} =  {'ChinaAll','India','Russia','Pakistan','Bangladesh'};


GitHubLink    = 'https://github.com/CSSEGISandData/COVID-19/archive/master.zip';
covid_version = 'CAAT | A. Esposito (v4.4)';

folder        = './DATA/COVID-19-master/COVID-19-master/csse_covid_19_data/csse_covid_19_time_series/';
dea_file      = 'time_series_covid19_deaths_global.csv';
deaUS_file    = 'time_series_covid19_deaths_US.csv';
plot_type     = 3; % 1: absolute numbers 2: population fraction      3: population fraction and age-adjusted          
smooth_kernel = 3; % number of days to run averaging kernel                

%inferred from %https://www.medrxiv.org/content/10.1101/2020.02.25.20027672v2.full.pdf
age =   [ 0         10          20          30          40          50          60      70      80];
mor_h = [ .002      .002        .002        .01         .02         .04         .11     .26     .49];    % mortality estimates from hubei
mor_c = [ .001      .001        .001        .002        .005        .01         .025    .06     .13];   % mortality estimates from rest of China

% new rates - https://www.thelancet.com/pdfs/journals/laninf/PIIS1473-3099(20)30243-7.pdf
mor_f = [ .0000161  .0000695    .000309     .000844     0.00161     0.00595     .0193   .0428   .078]; % mortality estimates from mainland China, corrected

mor_s = mor_f; % select one of the above data series - currently moving to the latest estimates by Ferguson's lab

% The file 'WPP2019_POP_F07_1_POPULATION_BY_AGE_BOTH_SEXES.xlsx'
% store population data and it was downloaded from:
% https://population.un.org/

% function to compute age adjusted mortality
madj = @(m,p)sum(m.*p/sum(p));





%% Load data
warning off

% Check if UN population data has been already downloaded
if ~exist('DATA/UNpopulation.xlsx','file')
   display('Downloading UN population data') 
   mkdir('./DATA');
   websave('./DATA/UNpopulation.xlsx','https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/EXCEL_FILES/1_Population/WPP2019_POP_F07_1_POPULATION_BY_AGE_BOTH_SEXES.xlsx');
   display('Population data stored in ./DATA/') 
end

choice = questdlg('Would you like to download the latest data from Johns Hopkins GitHub repository?',covid_version);
switch lower(choice)
    case 'no'
        % Download the Johns Hopkins dataset from
        % https://github.com/CSSEGISandData/COVID-19
        % and update the following strings to point to the files as indicated
        % below:
        display('CAAT: using last dataset...')
        
    case 'yes'
        display('CAAT: updating dataset...')
        unzip(GitHubLink,'./DATA/COVID-19-master/')
        display('CAAT: update completed')
        
    otherwise
        error('option not supported')
end


%% read and parse international data
dea = readtable([folder dea_file],'readvariablenames',true);
nc  = height(dea);   % number of regions
nt  = width(dea)-4;  % number of days

%% Process China (Hubei / China / China-Hubei / World)
% It is interesting to have both data from mainland China and Hubei

% find China entries
idxChina = find(ismember(table2array(dea(:,2)),'China'));
idxHubei = find(ismember(table2array(dea(:,1)),'Hubei'));

dea(height(dea)+1,2)   = cell2table({'World'});
dea(height(dea),5:end) = array2table(sum(table2array(dea(:,5:end))));

deaChina = table2array(dea(idxChina,5:nt+4));
deaHubei = table2array(dea(idxHubei,5:nt+4));

dea(height(dea)+1,2)   = cell2table({'ChinaAll'});
dea(height(dea),5:end) = array2table(sum(deaChina));
 
dea(height(dea)+1,2)   = cell2table({'RestChina'});
dea(height(dea),5:end) = array2table(sum(deaChina)-deaHubei);

nc = height(dea);

% remove non-essential entries
dea.Lat = [];
dea.Long = [];

% Change name of countries in JH database to match UN naming
dea.Country_Region(find(ismember(dea.Country_Region,'Korea, South')))={'Republic of Korea'};
%dea.Country_Region(find(ismember(dea.Province_State,'Reunion')))={'R�union'};
dea.Country_Region(find(ismember(dea.Country_Region,'United Republic of Tanzania')))={'Tanzania'};
dea.Country_Region(find(ismember(dea.Country_Region,'Congo (Brazzaville)' )))={'Congo'};
dea.Country_Region(find(ismember(dea.Country_Region,'Congo (Kinshasa)')))={'Democratic Republic of the Congo'};
dea.Country_Region(find(ismember(dea.Country_Region,'Cote d''Ivoire')))={'C�te d''Ivoire'};
dea.Country_Region(find(ismember(dea.Country_Region,'Syria')))={'Syrian Arab Republic'};
dea.Country_Region(find(ismember(dea.Country_Region,'Brunei')))={'Brunei Darussalam'};
dea.Country_Region(find(ismember(dea.Country_Region,'Laos')))={'Lao People''s Democratic Republic'};
dea.Country_Region(find(ismember(dea.Country_Region,'Burma')))={'Myammar'};
dea.Country_Region(find(ismember(dea.Country_Region,'Vietnam')))={'Viet Nam'};
dea.Country_Region(find(ismember(dea.Country_Region,'Bolivia')))={'Bolivia (Plurinational State of)'};
dea.Country_Region(find(ismember(dea.Country_Region,'Venezuela')))={'Venezuela (Bolivarian Republic of)'};
dea.Country_Region(find(ismember(dea.Country_Region,'Moldova')))={'Republic of Moldova'};


% Aggregate data from Canada
idxCanada = find(ismember(table2array(dea(:,2)),'Canada'));
deaCanada = sum(table2array(dea(idxCanada,3:end)),1);
dea(idxCanada,:)=[];
dea(height(dea)+1,2)   = cell2table({'Canada'});
dea(height(dea),3:end) = array2table(deaCanada);
nc = height(dea);



% Aggregate data from Australia
idxAustralia = find(ismember(table2array(dea(:,2)),'Australia'));
deaAustralia = sum(table2array(dea(idxAustralia,3:end)),1);
dea(idxAustralia,:)=[];
dea(height(dea)+1,2)   = cell2table({'Australia'});
dea(height(dea),3:end) = array2table(deaAustralia);
nc = height(dea);

%% read and parse US data
deaUS = readtable([folder deaUS_file],'readvariablenames',true);
idxUS = find(ismember(deaUS.Admin2,'Unassigned')); % find only states

dea(nc+1:nc+numel(idxUS),3:end) = deaUS(idxUS,13:end);
dea(nc+1:nc+numel(idxUS),1)     = deaUS(idxUS,7);
dea(nc+1:nc+numel(idxUS),2)     = array2table(repmat({'US State'},[length(idxUS) 1]));
nc = height(dea);
clear idx

%% READ UN POPULATION DATA
 display('CAAT: reading UN population dataset...')
[num_un text_un raw_un] = xlsread('./DATA/UNpopulation.xlsx','ESTIMATES');

%%     2020 estimates  
idx = find(num_un(:,8)==2020);
UN_NAME = text_un(idx,3);
UN_DATA = 1000*num_un(idx,9:end);

% reshape/bin population pyramid
UN_DATA(:,1:8) = sum(reshape(UN_DATA(:,1:16),[size(UN_DATA,1) 2 8]),2);
UN_DATA(:,9) = sum(UN_DATA(:,17:end),2);
UN_DATA(:,10:end) = [];
clear idx

% Add entry for Hubei, China-Hubei and USA name to US, China and Iran...
UN_NAME{end+1} = 'Hubei';
UN_DATA(end+1,:) = 58.5e6*UN_DATA(find(ismember(UN_NAME,'China')),:)./sum(UN_DATA(find(ismember(UN_NAME,'China')),:));
UN_NAME{end+1} = 'RestChina';
UN_DATA(end+1,:) = UN_DATA(find(ismember(UN_NAME,'China')),:)-UN_DATA(end,:);
UN_NAME{find(ismember(UN_NAME,'United States of America'))} = 'US';
UN_NAME{find(ismember(UN_NAME,'China'))} = 'ChinaAll';
UN_NAME{find(ismember(UN_NAME,'Iran (Islamic Republic of)'))} = 'Iran';
UN_NAME{find(ismember(UN_NAME,'Russian Federation'))} = 'Russia';

% Complement  UN data on countries with USA population sizes
% I do not have population pyramids for US states, so I will consider the
% demographic identical in each state. This is of course incorrect, but I
% do not expect massive changes.
%UN_NAME{end+1:end+1+length(idxUS)} = deaUS(idxUS,7);
%UN_DATA(end+1:end+1+length(idxUS),:) = state population * UN_DATA(find(ismember(UN_NAME,'US')),:)/sum(UN_DATA(find(ismember(UN_NAME,'US')),:));

display('CAAT: UN population data loaded');


%%
% Scan of the the list of plots
for ip = 1 : length(plot_countries)
     
    pop_t = 0;
    deaths = table2array(dea(:,3:nt+2));
    
    nr = length(plot_countries{ip});
    idxJH = NaN*zeros([nr 1]);
    idxUN = NaN*zeros([nr 1]);
        
    % Scan each region/country within each list
    for ir=1:nr
        tmp_idx = find(strcmp(dea.Country_Region,plot_countries{ip}{ir}));
        % find the region/country
        switch length(tmp_idx)
            case 1 % unique country name identified
                idxJH(ir)=tmp_idx;
            case 0 % probably not a country, scan region
                idxJH(ir) = find(strcmp(dea.Province_State,plot_countries{ip}{ir}));
            otherwise % probably multiple territories, identify country
                idxJH(ir) = tmp_idx(find(strcmp(dea.Province_State(tmp_idx),'')));        
        end
        
        idxUN(ir) = find(strcmp(UN_NAME,plot_countries{ip}{ir}));
    end

    deaths = deaths(idxJH,:); % delete uneccessary rows

    %
    if smooth_kernel>0
        deaths = imfilter(deaths, fspecial('average',[1 smooth_kernel]), 'replicate');
    end
    newdeaths = diff([zeros([nr 1]) deaths],1,2);




    hf = figure('Units','normalized','position',[0 0 1 1]);
    hold all

    ha1 = gca;
    col = get(ha1,'colororder');
    box on, axis square
    ha2=axes('position',[.25 .6 .2 .3])
    box on
    set([ha1 ha2],'colororder',reshape(repmat(col,[1 2])',3,[])')

    pop_s = [];
    for ic=1:nr
        switch plot_type
            case 1 % absolute number
                pop_n     = 1;
                pop_s(ic) = sum(UN_DATA(find(ismember(UN_NAME,plot_countries{ip}{ic})),:));
            case 2 % population fraction
                pop_n     = sum(UN_DATA(find(ismember(UN_NAME,plot_countries{ip}{ic})),:));
                pop_s(ic) = pop_n;
            case 3 % population fraction and age-adjusted
                pop_n = sum(UN_DATA(find(ismember(UN_NAME,plot_countries{ip}{ic})),:))*madj(mor_s,UN_DATA(find(ismember(UN_NAME,plot_countries{ip}{ic})),:));   
                pop_s(ic) = pop_n;
        end
    
        plot(ha1,deaths(ic,1:end)'/pop_n,newdeaths(ic,1:end)'./pop_n,'-','linewidth',3);
        newdeaths_marker = newdeaths(ic,end)'./pop_n;
        if newdeaths_marker>0
            %plot(deaths(ic,end-round(smooth_kernel/2))'/pop_n,newdeaths_marker,'.','markersize',50);
            plot(ha1,deaths(ic,end)'/pop_n,newdeaths_marker,'.','markersize',50);
        else
            plot(ha1,deaths(ic,end)'/pop_n,min(nonzeros(newdeaths(ic,:)'./pop_n)),'x','markersize',20);
            min(nonzeros(newdeaths(ic,:)'./pop_n))
        end
        pop_t = pop_t + pop_n;
    end
    set(ha1,'xscale','log','yscale','log')
    
    hb = bar(ha2,[deaths(:,end) pop_s'-deaths(:,end)],'stacked','facecolor','flat')
    hb(1).CData = 0.2*col(1:size(hb(1).CData,1),:);
    hb(2).CData = col(1:size(hb(2).CData,1),:);
    
    % plot reference line
    switch plot_type
        case 1 % absolute
            plot(ha1,(1:1e4:1e5),.25*(1:1e4:1e5),'k')
            xlabel(ha1,'fatalities (# people)')
            ylabel(ha1,'new fatalities (# people)')
            ylabel(ha2,'total population')
        case 2 % relative
            plot(ha1,(1e-9:1e-6:5e-4),.25*(1e-9:1e-6:5e-4),'k')
            xlabel(ha1,'fatalities (fraction of population)')
            ylabel(ha1,'new fatalities (fraction of population)')
            ylabel(ha2,'total population')
        case 3 % relative - adjusted
            plot(ha1,(1e-7:1e-6:1),.25*(1e-7:1e-6:1),'k')
            xlabel(ha1,'fatalities (fraction of population at risk - age adjusted)')
            ylabel(ha1,'new fatalities (fraction of population at risk - age adjusted)')
            ylabel(ha2,'population at risk')
    end
    set(ha2,'xtick',[])
    xlabel(ha2,'country')
    
   
    
    legend(ha1,[reshape(repmat(plot_countries{ip},[2 1]),1,[]),'reference'],'location','eastoutside')
    
    
    drawnow
    saveas(hf,[num2str(plot_type) '-' num2str(ip) '.png'])
   
   % close(hf)
end

%% Bar plots for relative fatalities within the population at risk
[pop_risk idxJH cur_deaths we1_deaths we2_deaths]= deal([]);
[pop_name region_not_found] = deal({});
counter = 0;

% Search UN population data to estimate size of population at risk in each
% listed region

for ic=1:numel(UN_NAME)
    country_name = UN_NAME{ic};
    pop_risk(ic) = sum(UN_DATA(find(ismember(UN_NAME,country_name)),:))*madj(mor_s,UN_DATA(find(ismember(UN_NAME,country_name)),:)); 
    
    % search correspondent entry in John Hopkins dataset
    % not all UN entry will have a JH entry, catch errors
    try
        tmp_idx = find(strcmp(dea.Country_Region,country_name));
    
        switch length(tmp_idx)
            case 1 % unique country name identified
                idxJH(ic)=tmp_idx;
            case 0 % probably not a country, scan region
                idxJH(ic) = find(strcmp(dea.Province_State,country_name));
            otherwise % probably multiple territories, identify country
                idxJH(ic) = tmp_idx(find(strcmp(dea.Province_State(tmp_idx),'')));        
        end
        
        cur_deaths(ic) = table2array(dea(idxJH(ic),end));    % current fatalities
        we1_deaths(ic) = table2array(dea(idxJH(ic),end-7));  % a week ago
        we2_deaths(ic) = table2array(dea(idxJH(ic),end-14)); % 2 weeks ago 
        we3_deaths(ic) = table2array(dea(idxJH(ic),end-21)); % 3 weeks ago 
        we4_deaths(ic) = table2array(dea(idxJH(ic),end-28)); % 4 weeks ago 
    catch
        % for debugging, store list of unmatched regions
        counter = counter + 1;
        region_not_found{counter} = country_name;
        cur_deaths(ic) = NaN;
    end
end

% top n_max countries (no... it is not a race! just vis purposes)
n_max = 50;

% fatalities relative to population at risk
p_deaths  = 100*cur_deaths./pop_risk;
% weekly increase of relative fatalities
d1_deaths = 100*(cur_deaths-we1_deaths)./pop_risk;
d2_deaths = 100*(we1_deaths-we2_deaths)./pop_risk;
d3_deaths = 100*(we2_deaths-we3_deaths)./pop_risk;
d4_deaths = 100*(we3_deaths-we4_deaths)./pop_risk;

countries = UN_NAME;

% remove records from unmatched regions
countries(isnan(p_deaths))=[];
d1_deaths(isnan(p_deaths))=[];
d2_deaths(isnan(p_deaths))=[];
d3_deaths(isnan(p_deaths))=[];
d4_deaths(isnan(p_deaths))=[];
p_deaths(isnan(p_deaths)) =[];

[dmb p_ord] = sort(p_deaths,'desc');  % ranking for relative fatalities
[dmb d_ord] = sort(d1_deaths,'desc'); % ranking for fatality rate, according to current week

%d_ord = p_ord;

% display
figure

subplot(1,2,1)
barh(p_deaths(p_ord(1:n_max)))
set(gca,'ytick',(1:n_max),'yticklabel',countries(p_ord(1:n_max)),'ydir','reverse','xgrid','on')
%xtickangle(90)
title('relative fatalities in the population at risk (since January)')
xlabel('fraction (%)')

subplot(1,2,2)
barh([d1_deaths(d_ord(1:n_max)); d2_deaths(d_ord(1:n_max)); d3_deaths(d_ord(1:n_max)); d4_deaths(d_ord(1:n_max))]','stacked')
set(gca,'ytick',(1:n_max),'yticklabel',countries(d_ord(1:n_max)),'ydir','reverse','xgrid','on')
%xtickangle(90)
title('weekly rate of increase (last month overview)')
xlabel('fraction (%)')
legend({'Current week','Last week','2 weeks ago','3 weeks ago'})




