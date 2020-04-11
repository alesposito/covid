%
folder = 'C:\Users\ae275\Desktop\COVID-19-master\csse_covid_19_data\csse_covid_19_time_series\';

age             = [ 0     10    20  30    40   50  60   70   80];
mortality_hubei = [ .002 .002 .002  .01  .02  .04  .11  .26 .49];
mortality_else  = [ .001 .001 .001  .002 .005  .01 .025 .06  .13];

% Population piramid - ITALY
pp = readtable([folder '../../' 'Italy-2019.csv']);
pp_IT = pp.F(1:16)+pp.M(1:16);
pp_IT = sum(reshape(pp_IT,[2 8]));
pp_IT(end+1) = sum(pp.F(17:end)+pp.M(17:end));
clear pp

% Population piramid - GERMANY
pp = readtable([folder '../../' 'Germany-2019.csv']);
pp_DL = pp.F(1:16)+pp.M(1:16);
pp_DL = sum(reshape(pp_DL,[2 8]));
pp_DL(end+1) = sum(pp.F(17:end)+pp.M(17:end));
clear pp

% expected mean age of fatalities - ITALY
mean_IT1 = sum( age .* (mortality_hubei.*pp_IT/sum(pp_IT.*mortality_hubei)))
mean_IT2 = sum( age .* (mortality_else.*pp_IT/sum(pp_IT.*mortality_else)))

% expected mean age of fatalities - GERMANY
mean_DL1 = sum( age .* (mortality_hubei.*pp_DL/sum(pp_DL.*mortality_hubei)))
mean_DL2 = sum( age .* (mortality_else.*pp_DL/sum(pp_DL.*mortality_else)))

% expected maean age
mean_IT3 = sum( age .* (pp_IT/sum(pp_IT)))
mean_DL3 = sum( age .* (pp_DL/sum(pp_DL)))

% expected median age - ITALY
ai = (0:.1:80);
pi_IT = interp1(age,pp_IT,ai);
pi_IT = cumsum(pi_IT./sum(pi_IT));
median_IT3 = ai(min(find(pi_IT>=0.5)))

% expected median age - GERMANY
pi_DL = interp1(age,pp_DL,ai);
pi_DL = cumsum(pi_DL./sum(pi_DL));
median_DL3 = ai(min(find(pi_DL>=0.5)))

% expected median age of fatalities - ITALY
mi_HU = interp1(age,mortality_hubei,ai);
mi_CH = interp1(age,mortality_else,ai);
mi_IT = cumsum((mi_HU.*pi_IT)/sum(mi_HU.*pi_IT));
median_IT1 = ai(min(find(mi_IT>=0.5)))
mi_IT2 = cumsum((mi_CH.*pi_IT)/sum(mi_CH.*pi_IT));
median_IT2 = ai(min(find(mi_IT2>=0.5)))

% expected median age of fatalities - GERMANY
mi_DL = cumsum((mi_HU.*pi_DL)/sum(mi_HU.*pi_DL));
median_DL1 = ai(min(find(mi_DL>=0.5)))
mi_DL2 = cumsum((mi_CH.*pi_DL)/sum(mi_CH.*pi_DL));
median_DL2 = ai(min(find(mi_DL2>=0.5)))



