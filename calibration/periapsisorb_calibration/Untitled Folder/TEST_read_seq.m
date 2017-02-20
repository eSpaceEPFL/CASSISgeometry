clear all;
close all;

path = '/HDD1/Data/CASSIS/2016_11_01_MARS/level1';

[t, exp, pac] = cassis_find_packages(path);
seq = cassis_find_seq(t, exp)

% take all frames that 
% * 0 sequence
% * 2 pac
ind = (seq == 3) & (pac == 2)
t = t(ind);
exp = exp(ind);
pac = pac(ind);

nb_pac = length(pac);
for npac = 1:nb_pac 
    [I{npac}, win, exp] = cassis_read_pac(path, t(npac), pac(npac), 'float=>float');
end

[dx, dy] = cassis_register_pac( I{1}, I{2})


