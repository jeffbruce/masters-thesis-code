% hVd_heatmap_folder.m
% hVd_heatmap_folder(Cmatrices)
%
% Purpose: generate hVd heatmap between hearing aid conditions.
%
% Input: cell array (n subjects * 3 noise conditions), each cell containing
%        an 11x11 confusion matrix (type int)
%
% Output: 2 heatmaps: 1 for each HA type.  need to set noise condition 
%         manually.
%
% Note: heatmap is different than HeatMap!  HeatMap is included in Matlab's
% toolboxes, heatmap was downloaded off the mathworks community site.
function hVd_heatmap_folder(Cmatrices)

n = length(Cmatrices)/2;  % number of subjects
words = 20;  % the total number of presentations of a single word

labels = {'had' 'hawed' 'hayed' 'head' 'heard' 'heed' 'hid' 'hoed' 'hood' 'hud' 'whod'};
CmatHA1 = cell(1,3);
CmatHA2 = cell(1,3);

CmatHA1{1} = Cmatrices{1,1};
CmatHA1{2} = Cmatrices{1,2};
CmatHA1{3} = Cmatrices{1,3};
CmatHA2{1} = Cmatrices{1+n,1};
CmatHA2{2} = Cmatrices{1+n,2};
CmatHA2{3} = Cmatrices{1+n,3};

for i = 2 : n
    CmatHA1{1} = CmatHA1{1} + Cmatrices{i,1};
    CmatHA1{2} = CmatHA1{2} + Cmatrices{i,2};
    CmatHA1{3} = CmatHA1{3} + Cmatrices{i,3};
    CmatHA2{1} = CmatHA2{1} + Cmatrices{i+n,1};
    CmatHA2{2} = CmatHA2{2} + Cmatrices{i+n,2};
    CmatHA2{3} = CmatHA2{3} + Cmatrices{i+n,3};
end

%normalize to percentages
CmatHA1{1} = CmatHA1{1}/(n*words/2)*100;
CmatHA2{1} = CmatHA2{1}/(n*words/2)*100;
CmatHA1{2} = CmatHA1{2}/(n*words/2)*100;
CmatHA2{2} = CmatHA2{2}/(n*words/2)*100;
CmatHA1{3} = CmatHA1{3}/(n*words)*100;
CmatHA2{3} = CmatHA2{3}/(n*words)*100;

figure(1);
hold on
subplot(2,1,1);
% no colorbar
hobj = heatmap(CmatHA1{1}, labels, labels, '%0.0f', 'ShowAllTicks', true, 'TickFontSize', 12, 'ColorMap', 'money');
% colorbar: can't set the min and max, which is misleading.
%heatmap(C33pcent, labels, labels, '%0.2f', 'ShowAllTicks', true, 'TickFontSize', 14, 'ColorMap', 'money', 'ColorBar', true);
xlabel('Response','FontSize',14);
ylabel('Stimulus','FontSize',14);
title('hVd Confusion Matrix (Quiet) - NC','FontSize',16);

subplot(2,1,2);
% no colorbar
hobj = heatmap(CmatHA2{1}, labels, labels, '%0.0f', 'ShowAllTicks', true, 'TickFontSize', 12, 'ColorMap', 'money');
% colorbar: can't set the min and max, which is misleading.
%heatmap(C33pcent, labels, labels, '%0.2f', 'ShowAllTicks', true, 'TickFontSize', 14, 'ColorMap', 'money', 'ColorBar', true);
xlabel('Response','FontSize',14);
ylabel('Stimulus','FontSize',14);
title('hVd Confusion Matrix (Quiet) - WDRC','FontSize',16);
hold off

figure(2);
hold on
subplot(2,1,1);
% no colorbar
hobj = heatmap(CmatHA1{2}, labels, labels, '%0.0f', 'ShowAllTicks', true, 'TickFontSize', 12, 'ColorMap', 'money');
% colorbar: can't set the min and max, which is misleading.
%heatmap(C33pcent, labels, labels, '%0.2f', 'ShowAllTicks', true, 'TickFontSize', 14, 'ColorMap', 'money', 'ColorBar', true);
xlabel('Response','FontSize',14);
ylabel('Stimulus','FontSize',14);
title('hVd Confusion Matrix (Noise) - NC','FontSize',16);

subplot(2,1,2);
% no colorbar
hobj = heatmap(CmatHA2{2}, labels, labels, '%0.0f', 'ShowAllTicks', true, 'TickFontSize', 12, 'ColorMap', 'money');
% colorbar: can't set the min and max, which is misleading.
%heatmap(C33pcent, labels, labels, '%0.2f', 'ShowAllTicks', true, 'TickFontSize', 14, 'ColorMap', 'money', 'ColorBar', true);
xlabel('Response','FontSize',14);
ylabel('Stimulus','FontSize',14);
title('hVd Confusion Matrix (Noise) - WDRC','FontSize',16);
hold off

figure(3);
hold on
subplot(2,1,1);
% no colorbar
hobj = heatmap(CmatHA1{3}, labels, labels, '%0.0f', 'ShowAllTicks', true, 'TickFontSize', 12, 'ColorMap', 'money');
% colorbar: can't set the min and max, which is misleading.
%heatmap(C33pcent, labels, labels, '%0.2f', 'ShowAllTicks', true, 'TickFontSize', 14, 'ColorMap', 'money', 'ColorBar', true);
xlabel('Response','FontSize',14);
ylabel('Stimulus','FontSize',14);
title('hVd Confusion Matrix (Overall) - NC','FontSize',16);

subplot(2,1,2);
% no colorbar
hobj = heatmap(CmatHA2{3}, labels, labels, '%0.0f', 'ShowAllTicks', true, 'TickFontSize', 12, 'ColorMap', 'money');
% colorbar: can't set the min and max, which is misleading.
%heatmap(C33pcent, labels, labels, '%0.2f', 'ShowAllTicks', true, 'TickFontSize', 14, 'ColorMap', 'money', 'ColorBar', true);
xlabel('Response','FontSize',14);
ylabel('Stimulus','FontSize',14);
title('hVd Confusion Matrix (Overall) - WDRC','FontSize',16);
hold off

figure(4);
hobj = heatmap(CmatHA1{1}-CmatHA2{1}, labels, labels, '%0.0f', 'ShowAllTicks', true, 'TickFontSize', 12, 'ColorMap', 'money', 'Colorbar', true);
xlabel('Response','FontSize',14);
ylabel('Stimulus','FontSize',14);
title('hVd Confusion Matrix (Quiet): (NC - WDRC)','FontSize',16);

figure(5);
hobj = heatmap(CmatHA1{2}-CmatHA2{2}, labels, labels, '%0.0f', 'ShowAllTicks', true, 'TickFontSize', 12, 'ColorMap', 'money', 'Colorbar', true);
xlabel('Response','FontSize',14);
ylabel('Stimulus','FontSize',14);
title('hVd Confusion Matrix (Noise): (NC - WDRC)','FontSize',16);

figure(6);
hobj = heatmap(CmatHA1{3}-CmatHA2{3}, labels, labels, '%0.0f', 'ShowAllTicks', true, 'TickFontSize', 12, 'ColorMap', 'money', 'Colorbar', true);
xlabel('Response','FontSize',14);
ylabel('Stimulus','FontSize',14);
title('hVd Confusion Matrix (Overall): (NC - WDRC)','FontSize',16);