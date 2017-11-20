%
% subjfile specifies subjects by normal hearing or HAs
% the file is typically called "all_subjects.txt", though there is nothing
% special about this name
function [norm_ovr_avg, HA_ovr_avg, norm_std, HA_std] = plot_audiograms(subjfile)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile, '.txt');
[norm_subs HA_subs] = textread(filename, '%s %s', 'headerlines', 1);

% this whole block makes it so empty strings are ignored -- ideally it
% would be a subfunction
norm_subs_empty = min(find(strcmp(norm_subs,'')));
HA_subs_empty = min(find(strcmp(HA_subs,'')));
if ~(isempty(norm_subs_empty))
    norm_subs = norm_subs(1:norm_subs_empty-1);
end
if ~(isempty(HA_subs_empty))
    HA_subs = HA_subs(1:HA_subs_empty-1);
end

% CALCULATE AVERAGED NORMAL AUDIOGRAMS
normal_avg = zeros(2,8);
norm_resid = zeros(1,8);
for i=1:length(norm_subs)
    filename = strcat(curpath, 'data\', norm_subs{i}, '.xlsx');
    audiogram = xlsread(filename);
    audiogram = audiogram(2:3,:);
    normal_avg = normal_avg + audiogram;
end
normal_avg = normal_avg/length(norm_subs);
norm_ovr_avg = mean(normal_avg);
for i=1:length(norm_subs)
    filename = strcat(curpath, 'data\', norm_subs{i}, '.xlsx');
    audiogram = xlsread(filename);
    audiogram = audiogram(2:3,:);
    audiogram = mean(audiogram);
    norm_resid = (norm_ovr_avg - audiogram).^2 + norm_resid;
end
norm_std = sqrt(norm_resid/(length(norm_subs)-1));

% CALCULATE AVERAGED HA AUDIOGRAMS
HA_avg = zeros(2,8);
HA_resid = zeros(1,8);
for i=1:length(HA_subs)
    filename = strcat(curpath, 'data\', HA_subs{i}, '.xlsx');
    audiogram = xlsread(filename);
    audiogram = audiogram(2:3,:);
    HA_avg = HA_avg + audiogram;
end
HA_avg = HA_avg/length(HA_subs);
HA_ovr_avg = mean(HA_avg);
for i=1:length(HA_subs)
    filename = strcat(curpath, 'data\', HA_subs{i}, '.xlsx');
    audiogram = xlsread(filename);
    audiogram = audiogram(2:3,:);
    audiogram = mean(audiogram);
    HA_resid = (HA_ovr_avg - audiogram).^2 + HA_resid;
end
HA_std = sqrt(HA_resid/(length(HA_subs)-1));

xlabels = [250 500 1000 2000 3000 4000 6000 8000];
% PLOT LEFT and RIGHT AVERAGED NORMAL AUDIOGRAMS
%figure(1);
%semilogx(xlabels,normal_avg(1,:),'-or',xlabels,normal_avg(2,:),'-ob');

% PLOT LEFT and RIGHT AVERAGED HA AUDIOGRAMS
%figure(2);
%semilogx(xlabels,HA_avg(1,:),'-or',xlabels,HA_avg(2,:),'-ob');

% PLOT NORMAL AND HA AUDIOGRAMS ON SAME PLOT
figure(3);
semilogx(xlabels,norm_ovr_avg,'-ob',xlabels,HA_ovr_avg,'-xr');
title('Pure Tone Audiograms','FontSize',24)
xlabel('Frequency (Hz)','FontSize',20);
ylabel('Pure Tone Threshold (dB HL)','FontSize',20);
h_legend = legend('Normal','HA');
set(h_legend,'FontSize',18);
set(gca,'FontSize',16)

xlswrite('audiogram data.xls', [norm_ovr_avg; HA_ovr_avg; norm_std; HA_std]);

end