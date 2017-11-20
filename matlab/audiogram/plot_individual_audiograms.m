% plot_individual_audiograms.m
%
% [norm_ovr_avg, HA_ovr_avg, norm_std, HA_std] = plot_individual_audiograms(subjfile)
%
% Purpose: for each name in subjfile, plot old audiograms and new
%          audiograms for each ear.  each subject gets her own plot.
%
% Input: subjfile (string), usually called 'all_subjects'
%
% Output: some vars apparently
function [norm_ovr_avg, HA_ovr_avg, norm_std, HA_std] = plot_individual_audiograms(subjfile)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile, '.txt');
[subjects] = textread(filename, '%s');
subjdata = cell(length(subjects),1);

% READ IN AUDIOGRAMS
for i=1:length(subjects)
    filename = strcat(curpath, 'data\', subjects{i}, '.xlsx');
    audiogram = xlsread(filename);
    audiogram = audiogram(2:3,:);
    subjdata{i} = mean(audiogram);
end
xlabels = [250 500 1000 2000 3000 4000 6000 8000];

% PLOT ALL SUBJECT AUDIOGRAMS ON SAME PLOT
figure(1);
hold on
for i=1:length(subjects)
    semilogx(xlabels,subjdata{i},'-ob');
end
hold off
    
title('Pure Tone Audiograms','FontSize',24)
xlabel('Frequency (Hz)','FontSize',20);
ylabel('Pure Tone Threshold (dB HL)','FontSize',20);
%h_legend = legend('Normal','HA');
%set(h_legend,'FontSize',18);
set(gca,'FontSize',16)

%xlswrite('audiogram data.xls', [norm_ovr_avg; HA_ovr_avg; norm_std; HA_std]);

end