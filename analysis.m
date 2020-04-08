%% Load data
clear all
close all

% https://github.com/CSSEGISandData/COVID-19
folder = 'C:\Users\ae275\Desktop\COVID-19-master\csse_covid_19_data\csse_covid_19_time_series\';
dea_file = 'time_series_covid19_deaths_global.csv';
dea = readtable([folder dea_file],'readvariablenames',true);

% define the population of different regions
population = table([60.5e6   66.4e6        58.5e6   372e6  1.38e9    82.8e6    67e6     46.7e6  10.1e6   5.6e6     17.2e6        11.4e6    7.8e9   5.4e6   5.5e6       8.8e6     8.6e6]',...
                   {'Italy','United Kingdom','Hubei','US','ChinaAll','Germany','France','Spain','Sweden','Denmark','Netherlands','Belgium','World','Norway','Finland','Austria','Switzerland'}',...
                   'VariableNames',{'Size','Region'});

nc = height(dea);   % number of regions
nt = width(dea)-4;  % number of days

%% Process China (Hubei / China / China-Hubei / World)


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

%%     
plot_countries{1} =  {'Italy','United Kingdom','Hubei','ChinaAll','US'}
plot_countries{2} =  {'Italy','United Kingdom','Germany','France','Spain'}
plot_countries{3} =  {'Italy','Sweden','Denmark','Norway','Finland'}
plot_countries{4} =  {'Italy','Netherlands','Belgium','France'}
plot_countries{5} =  {'Italy','Netherlands','Germany','Austria','Switzerland'}


plot_type = 1; % 1: absolute numbers 2: population fraction              
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
            xlabel('fatalities (% of population)')
            ylabel('new fatalities (% of population)')
    end
    legend([reshape(repmat(plot_countries{ip},[2 1]),1,[]),'average'],'location','eastoutside')
    box on, axis square
    
    saveas(hf,[num2str(plot_type) '-' num2str(ic) '.png'])
end



