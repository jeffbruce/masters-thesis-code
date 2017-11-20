% analyze_loc_laser.m
%
% Takes as input a subject name and subject number, and calculates the
% mean absolute error on each speaker for each condition (low/high/phone).
%
% input: subjname (arg1) (a string representing the subject name), 
%        num (arg2) (also a string, representing the HA num)
%
% output: lowfreq -> raw data on the lowfreq condition
%         highfreq -> raw data on the highfreq condition
%         phone -> raw data on the phone condition
%         avgerror -> the average error for each speaker/condition
%         ovrerror -> a complete average error by condition
function [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(subjname, num, varargin)

% GET DIRECTORY THIS M FILE RESIDES IN
curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

avgerror = zeros(7,3);
ovrerror = zeros(1,3);

% PROCESS ALL CONDITIONS (left_low, left_high, right_low, right_high, left_phone, right_phone)
% notice the odd order here.  reason is because the phone condition was
% added late to the experiment.
for j = 1:6

    % READ IN TABLE CORRESPONDING TO CORRECT CONDITION
    if j == 1
        filename = strcat(curpath, 'data\left\low\', subjname, num, '.txt');
        [a b c d e] = textread(filename, '%n %n %n %n %n', 'headerlines', 1);
    elseif j == 2
        filename = strcat(curpath, 'data\left\high\', subjname, num, '.txt');
        [a b c d e] = textread(filename, '%n %n %n %n %n', 'headerlines', 1);
    elseif j == 3
        filename = strcat(curpath, 'data\right\low\', subjname, num, '.txt');
        [a b c d e] = textread(filename, '%n %n %n %n %n', 'headerlines', 1);
    elseif j == 4
        filename = strcat(curpath, 'data\right\high\', subjname, num, '.txt');
        [a b c d e] = textread(filename, '%n %n %n %n %n', 'headerlines', 1);
    elseif j == 5
        filename = strcat(curpath, 'data\left\phone\', subjname, num, '.txt');
        [a b c d e] = textread(filename, '%n %n %n %n %n', 'headerlines', 1);
    else  % j == 6
        filename = strcat(curpath, 'data\right\phone\', subjname, num, '.txt');
        [a b c d e] = textread(filename, '%n %n %n %n %n', 'headerlines', 1);
    end
    
    % M CONTAINS ALL OBSERVATIONS
    M = [a b c d e];
    M = sortrows(M, [3 1]);
    M = add_column(M);  % add a column for rms
    M = M(:, [1:3 5:6]);  % use only relevant columns
    
    % M PROPERTIES
    num_speakers = max(M(:,3));
    num_obs_per_speaker = length(find(M(:,3)==1));
   
    if j == 1
        left_low = M;
    elseif j == 2
        left_high = M;
    elseif j == 3
        right_low = M;
    elseif j == 4
        right_high = M;
    elseif j == 5
        left_phone = M;
    else  % j == 6
        right_phone = M;
    end

end

lowfreq = [left_low; right_low];
highfreq = [left_high; right_high];
phone = [left_phone; right_phone];

lowfreq = sortrows(lowfreq, [3]);
highfreq = sortrows(highfreq, [3]);
phone = sortrows(phone, [3]);

lowfreq = calc_MAE(lowfreq);
highfreq = calc_MAE(highfreq);
phone = calc_MAE(phone);

phone(:,2) = 15000;
alldata = [lowfreq; highfreq; phone];

for i = 1:7
    %avgmean(i,1) = mean(lowfreq(1+(i-1)*8:i*8,4));
    %avgmean(i,2) = mean(highfreq(1+(i-1)*8:i*8,4));
    %avgmean(i,3) = mean(phone(1+(i-1)*8:i*8,4));
    avgerror(i,1) = mean(lowfreq(1+(i-1)*8:i*8,5));
    avgerror(i,2) = mean(highfreq(1+(i-1)*8:i*8,5));
    avgerror(i,3) = mean(phone(1+(i-1)*8:i*8,5));
end

ovrerror = mean(avgerror);

% plots confusion matrices if not called from plot_loc_folder
if length(varargin) == 0
    plot_errors()
    plot_responses()
end

%avgMAEfreq(1) = mean(avgMAEcond([1 3]));
%avgMAEfreq(2) = mean(avgMAEcond([2 4]));

%xlswrite(strcat(curpath,'summary data/',subjname,'.xls'),lowfreq,'low');
%xlswrite(strcat(curpath,'summary data/',subjname,'.xls'),highfreq,'high');

% adds a column of zeros to matrix mat
function mat = add_column(mat)

matsize = size(mat);
mat(:,matsize(2)+1) = 0;

end

% adds a row of zeros to matrix mat
function mat = add_row(mat)

matsize = size(mat);
mat(matsize(1)+1,:) = 0;

end

% helper function to calculate MAE for the matrix M
function mat = calc_MAE(mat)

    for i=1:56
        mat(i,5) = mat(i,4) - (mat(i,3) - 1)*15;
        mat(i,5) = abs(mat(i,5));  % calculates the MAE
    end

end

function rereference()
% rereference spk1 = 0deg , ... , spk7 = 90deg
% this code will be unnecessary when i change coding in experiment to 
% reflect spk1 = 0deg, spk7 = 90deg
%for i = 1:56
%    lowfreq(i,4) = 90 - lowfreq(i,4);
%    highfreq(i,4) = 90 - highfreq(i,4);
%    phone(i,4) = 90 - phone(i,4);
%end       
end

function relabel()
% relabel speaker 7 as 1, 6 as 2, 5 as 3, in "right" conditions
    %if j == 3 || j == 4 || j == 6
    %    M(1:4,3) = 7;
    %    M(5:8,3) = 6;
    %    M(9:12,3) = 5;
    %    M(17:20,3) = 3;
    %    M(21:24,3) = 2;
    %    M(25:28,3) = 1;
    %    M = sortrows(M, [3 1]);  % -- and re-sort
    %end
end

% plots speaker/error confusion matrix
function plot_errors()
    mult = [1/3; 1/3; 1/3];
    speakeravg = avgerror*mult;
    figure(2); 
    hold on
    bar(0:15:90, speakeravg); 
    scatter(alldata(:,3)*15 - 15, alldata(:,5),'r');
    axis([0 90 0 90]);
    title('Stimulus Error Confusion Matrix');
    xlabel('speaker (degrees)');
    ylabel('error (degrees)');
    hold off
end

% plots speaker/response confusion matrix
function plot_responses()
    
    responseavg = zeros(7,1);
    for i=1:7
        indices = find(alldata(:,3)==i);
        responseavg(i) = mean(alldata(indices,4));
    end
    
    figure(1); 
    hold on
    bar(0:15:90, responseavg); 
    scatter(alldata(:,3)*15 - 15, alldata(:,4),'r');
    axis([0 90 0 90]);
    title('Stimulus Response Confusion Matrix');
    xlabel('speaker (degrees)');
    ylabel('response (degrees)');
    hold off
end

end