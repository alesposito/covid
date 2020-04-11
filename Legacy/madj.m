function [best worst] = madj(folder,file,mb,mw)

pp = readtable([folder '../../' file]);
ppa = pp.F(1:16)+pp.M(1:16);
ppa = sum(reshape(ppa,[2 8]));
ppa(end+1) = sum(pp.F(17:end)+pp.M(17:end));
worst= sum(mw.*ppa/sum(ppa));
best = sum(mb.*ppa/sum(ppa));