% plot_old_new_audiograms.m
%
% [norm_ovr_avg, HA_ovr_avg, norm_std, HA_std] = plot_old_new_audiograms(subjfile)
%
% Purpose: for each name in subjfile, plot old audiograms and new
%          audiograms for each ear.  each subject gets her own plot, in a
%          subplot.
%
% Input: subjfile (string), usually called 'all_subjects'
%
% Note: if there are no values anywhere in the old data, replace these
%       values with NaN
function plot_old_new_audiograms(subjfile)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile, '.txt');
[subjs] = textread(filename, '%s', 'headerlines', 0);
plotsize = find_plot_size(length(subjs));

xlabels = [250 500 1000 2000 3000 4000 6000 8000];

% loop through each subject, create 4 series for a subject, plot all on a
% semilog plot within a subplot
for i=1:length(subjs)
    filename = strcat(curpath, 'data\old\', subjs{i}, 'old', '.xlsx');
    audiogram = xlsread(filename);
    oldaudiogram = audiogram(2:3,:);
    indices = find(oldaudiogram == -1);
    oldaudiogram(indices) = NaN;
    filename = strcat(curpath, 'data\new\', subjs{i}, 'new', '.xlsx');
    audiogram = xlsread(filename);
    newaudiogram = audiogram(2:3,:);
    indices = find(newaudiogram == -1);
    newaudiogram(indices) = NaN;
    subplot(plotsize(1),plotsize(2),i);
    semilogx(xlabels,oldaudiogram(1,:),'-ob',xlabels,oldaudiogram(2,:),'-xb',xlabels,newaudiogram(1,:),'-or',xlabels,newaudiogram(2,:),'-xr');
    ylim([0 120]);
    title(strcat('Subject', num2str(i)), 'FontSize',14)
end
%xlabel('Frequency (Hz)','FontSize',14);
%ylabel('Threshold (dB HL)','FontSize',14);
h_legend = legend('Old-R','Old-L','New-R','New-L');
set(h_legend,'FontSize',14);
%set(gca,'FontSize',14)

% calculates optimal size for subplot
function plotsize = find_plot_size(len)
    
    height = ceil(sqrt(len));
    width = ceil(len/height);
    plotsize = [height; width];
    
end

end