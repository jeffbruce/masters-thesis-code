% parse data file, then concatenate lowfreq and highfreq matrices
[avgmean,avgstd,lowfreq,highfreq,phone] = analyze_loc('Sam', 1);
all = [lowfreq; highfreq; phone];

% create new column: speaker location in deg
for i = 1:length(all)
    all(i,6) = (all(i,3) - 1) * 15;
end
all = sortrows(all, [2 3 1]);

% low freq plot collapsed across orientation
%figure(1);
subplot(1,3,1);
scatter(all(1:56,6),all(1:56,4),'r')
hold on
plot([0 15 30 45 60 75 90], [0 15 30 45 60 75 90], 'g');
%B = barerrorbar({[90 75 60 45 30 15 0], avgmean(:,1), 'b'}, {[90 75 60 45 30 15 0], avgmean(:,1), avgstd(:,1)});
B = bar([0 15 30 45 60 75 90], avgmean(:,1), 'b');
ch = get(B,'child');
set(ch,'facea',.35);
set(gca,'XTick',-15:15:105);
xlim([-15 105]);
xlabel('Stimulus (°)');
set(gca,'YTick',0:15:105);
ylim([0 105]);
ylabel('Response (°)');
title('500Hz 1/3oct Band Response Distributions');
hold off

% high freq plot collapsed across orientation
%figure(2);
subplot(1,3,2);
scatter(all(57:112,6),all(57:112,4),'r')
hold on
plot([0 15 30 45 60 75 90], [0 15 30 45 60 75 90], 'g');
B = bar([0 15 30 45 60 75 90], avgmean(:,2), 'b');
ch = get(B,'child');
set(ch,'facea',.35);
set(gca,'XTick',-15:15:105);
xlim([-15 105]);
xlabel('Stimulus (°)');
set(gca,'YTick',0:15:105);
ylim([0 105]);
ylabel('Response (°)');
title('3000Hz 1/3oct Band Response Distributions');
hold off

% overall plot collapsed across freq and orientation
%figure(3);
subplot(1,3,3);
scatter(all(113:168,6),all(113:168,4),'r')
hold on
plot([0 15 30 45 60 75 90], [0 15 30 45 60 75 90], 'g');
B = bar([0 15 30 45 60 75 90], avgmean(:,3), 'b');
%B = bar([0 15 30 45 60 75 90], (avgmean(:,1)+avgmean(:,2))/2, 'b');
ch = get(B,'child');
set(ch,'facea',.35);
set(gca,'XTick',-15:15:105);
xlim([-15 105]);
xlabel('Stimulus (°)');
set(gca,'YTick',0:15:105);
ylim([0 105]);
ylabel('Response (°)');
title('Response Distributions for Both High+Low Freq Stim');
hold off