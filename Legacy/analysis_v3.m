%% Load data
clear all
close all

% Doenload the Johns Hopkins dataset from
% https://github.com/CSSEGISandData/COVID-19
% and update the following strings to point to the files as indicated
% below:
folder = 'C:\Users\ae275\Desktop\COVID-19-master\csse_covid_19_data\csse_covid_19_time_series\';
dea_file = 'time_series_covid19_deaths_global.csv';
deaUS_file = 'time_series_covid19_deaths_US.csv';


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

%% read and parse US data
deaUS = readtable([folder deaUS_file],'readvariablenames',true);
idxUS = find(ismember(deaUS.Admin2,'Unassigned')); % find only states

dea(nc:nc+numel(idxUS),5:end) = deaUS(idxUS,13:end);

nc = height(dea);
clear idx
%%
%inferred from %https://www.medrxiv.org/content/10.1101/2020.02.25.20027672v2.full.pdf
age             = [ 0     10    20  30    40   50  60   70   80];
mortality_hubei = [ .002 .002 .002  .01  .02  .04  .11  .26 .49];
mortality_else  = [ .001 .001 .001  .002 .005  .01 .025 .06  .13];
%download population data from 
%https://www.populationpyramid.net/
% age-adjustect fatality rates: 0: modellend on China outside Hubei, 1:
% modelled on Hubei
[adjCH0 adjCH1] = madj(folder,'China-2019.csv',mortality_else,mortality_hubei);
[adjIT0 adjIT1] = madj(folder,'Italy-2019.csv',mortality_else,mortality_hubei);
[adjUK0 adjUK1] = madj(folder,'United Kingdom-2019.csv',mortality_else,mortality_hubei);
[adjSK0 adjSK1] = madj(folder,'Republic of Korea-2019.csv',mortality_else,mortality_hubei);
[adjES0 adjES1] = madj(folder,'Spain-2019.csv',mortality_else,mortality_hubei);
[adjFR0 adjFR1] = madj(folder,'France-2019.csv',mortality_else,mortality_hubei);
[adjDL0 adjDL1] = madj(folder,'Germany-2019.csv',mortality_else,mortality_hubei);
[adjUS0 adjUS1] = madj(folder,'USA-2019.csv',mortality_else,mortality_hubei);
[adjWR0 adjWR1] = madj(folder,'World-2019.csv',mortality_else,mortality_hubei);
[adjSW0 adjSW1] = madj(folder,'Sweden-2019.csv',mortality_else,mortality_hubei);
[adjDN0 adjDN1] = madj(folder,'Denmark-2019.csv',mortality_else,mortality_hubei);
[adjNL0 adjNL1] = madj(folder,'Netherlands-2019.csv',mortality_else,mortality_hubei);
[adjBE0 adjBE1] = madj(folder,'Belgium-2019.csv',mortality_else,mortality_hubei);
[adjNW0 adjNW1] = madj(folder,'Norway-2019.csv',mortality_else,mortality_hubei);
[adjFI0 adjFI1] = madj(folder,'Finland-2019.csv',mortality_else,mortality_hubei);
[adjOS0 adjOS1] = madj(folder,'Austria-2019.csv',mortality_else,mortality_hubei);
[adjSZ0 adjSZ1] = madj(folder,'Switzerland-2019.csv',mortality_else,mortality_hubei);
[adjIR0 adjIR1] = madj(folder,'Iran-2019.csv',mortality_else,mortality_hubei);
[adjJP0 adjJP1] = madj(folder,'Japan-2019.csv',mortality_else,mortality_hubei);
[adjSG0 adjSG1] = madj(folder,'Singapore-2019.csv',mortality_else,mortality_hubei);

% define the population of different regions
population = table([60.5e6   66.4e6        58.5e6   372e6  1.38e9    82.8e6    67e6     46.7e6  10.1e6   5.6e6     17.2e6        11.4e6    7.8e9   5.4e6   5.5e6       8.8e6     8.6e6        82.9e6   126.9e6  51.2e6       5.8e6]',...
                   {'Italy','United Kingdom','Hubei','US','ChinaAll','Germany','France','Spain','Sweden','Denmark','Netherlands','Belgium','World','Norway','Finland','Austria','Switzerland','Iran','Japan','Korea, South','Singapore'}',...
                   [adjIT0   adjUK0           adjCH0 adjUS0 adjCH0    adjDL0    adjFR0   adjES0   adjSW0  adjDN0    adjNL0        adjBE0    adjWR0  adjNW0   adjFI0    adjOS0    adjSZ0       adjIR0   adjJP0 adjSK0         adjSG0]',...
                   'VariableNames',{'Size','Region','mortality'});
%%     
plot_countries{1} =  {'Italy','United Kingdom','Hubei','ChinaAll','US','Iran'}
plot_countries{2} =  {'Italy','United Kingdom','Germany','France','Spain'}
plot_countries{3} =  {'Italy','Sweden','Denmark','Norway','Finland'}
plot_countries{4} =  {'Italy','Netherlands','Belgium','France'}
plot_countries{5} =  {'Italy','Netherlands','Germany','Austria','Switzerland'}
plot_countries{6} =  {'Italy','Japan','Hubei','ChinaAll','Korea, South','Singapore'}


plot_type = 3; % 1: absolute numbers 2: population fraction      3: population fraction and age-adjusted          
smooth_kernel = 3; % number of days to run averaging kernel                


for ip = 1 : length(plot_countries)
     
    pop_t = 0;
    deaths = table2array(dea(:,5:nt+4));
    
    nr = length(plot_countries{ip});
    idx = ones([nr 1]);
    for ir=1:nr
        tmp_idx = find(strcmp(dea.Country_Region,plot_countries{ip}{ir}));

        switch length(tmp_idx)
            case 1 % unique country name identified
                idx(ir)=tmp_idx;
            case 0 % probably not a country, scan region
                idx(ir) = find(strcmp(dea.Province_State,plot_countries{ip}{ir}));
            otherwise % probably multiple territories, identify country
                idx(ir) = tmp_idx(find(strcmp(dea.Province_State(tmp_idx),'')));        
        end
    end

    deaths = deaths(idx,:); % delete uneccessary rows

    %
    if smooth_kernel>0
        deaths = imfilter(deaths, fspecial('average',[1 smooth_kernel]), 'replicate');
    end
    newdeaths = diff([zeros([nr 1]) deaths],1,2);




    hf = figure;
    hold all

    col = get(gca,'colororder');
    set(gca,'colororder',reshape(repmat(col,[1 2])',3,[])')

    
    for ic=1:nr
        switch plot_type
            case 1 % absolute number
                pop_n = 1;
            case 2 % population fraction
                idx   = find(strcmp(population.Region,plot_countries{ip}{ic}));
                pop_n = population.Size(idx);
            case 3 % population fraction and age-adjusted
                idx   = find(strcmp(population.Region,plot_countries{ip}{ic}));
                pop_n = population.Size(idx)*population.mortality(idx);               
        end
    
        plot(deaths(ic,1:end-round(smooth_kernel/2))'/pop_n,newdeaths(ic,1:end-round(smooth_kernel/2))'./pop_n,'-','linewidth',3);
        plot(deaths(ic,end-round(smooth_kernel/2))'/pop_n,newdeaths(ic,end-round(smooth_kernel/2))'./pop_n,'.','markersize',50);
        pop_t = pop_t + pop_n;
    end
    set(gca,'xscale','log','yscale','log')
    % plot reference line
    switch plot_type
        case 1 % absolute
            plot((1:1e4:1e5),.25*(1:1e4:1e5),'k')
            xlabel('fatalities (# people)')
            ylabel('new fatalities (# people)')
        case 2 % relative
            plot((1e-9:1e-6:5e-4),.25*(1e-9:1e-6:5e-4),'k')
            xlabel('fatalities (fraction of population)')
            ylabel('new fatalities (fraction of population)')
        case 3 % relative - adjusted
            plot((1e-7:1e-6:1),.25*(1e-7:1e-6:1),'k')
            xlabel('fatalities (fraction of population at risk - age adjusted)')
            ylabel('new fatalities (fraction of population at risk - age adjusted)')
    end
    legend([reshape(repmat(plot_countries{ip},[2 1]),1,[]),'average'],'location','eastoutside')
    box on, axis square
    
    drawnow
    saveas(hf,[num2str(plot_type) '-' num2str(ip) '.png'])
   
   % close(hf)
end



