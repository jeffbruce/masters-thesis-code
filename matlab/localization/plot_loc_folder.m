% plot_loc_folder.m
%
% input: subjfile (a filename specifying the names of the subjects to 
% analyze, one per line)
%
% output: an Excel file listing subject number, name, overall error
function plot_loc_folder(subjfile)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile, '.txt');
[sf] = textread(filename, '%s');
subjnames = [sf];
plotsize = find_plot_size(length(subjnames));

figure(1);
for i=1:length(subjnames)
    
    subject = subjnames{i};
    name = subject(1:end-2);
    num = subject(end-1:end);
        
    % supply a 0 as an argument to suppress any plots in analyze_loc
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc(name, num, 0);
    alldata = [lowfreq;highfreq;phone];
    
    subplot(plotsize(1),plotsize(2),i);
    plot_responses();
    
end

figure(2);
for i=1:length(subjnames)
    
    subject = subjnames{i};
    name = subject(1:end-2);
    num = subject(end-1:end);
        
    % supply a 0 as an argument to suppress any plots in analyze_loc
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc(name, num, 0);
    alldata = [lowfreq;highfreq;phone];
    
    subplot(plotsize(1),plotsize(2),i);
    plot_errors();
    
end

% plots speaker/error confusion matrix
function plot_errors()
    mult = [1/3; 1/3; 1/3];
    speakeravg = avgerror*mult;
    hold on
    bar(0:15:90, speakeravg); 
    scatter(alldata(:,3)*15 - 15, alldata(:,5),'r');
    axis([0 90 0 90]);
    %title('Stimulus Error Confusion Matrix');
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
    
    hold on
    bar(0:15:90, responseavg); 
    scatter(alldata(:,3)*15 - 15, alldata(:,4),'r');
    axis([0 90 0 90]);
    %title('Stimulus Response Confusion Matrix');
    xlabel('speaker (degrees)');
    ylabel('response (degrees)');
    hold off
end

% calculates optimal size for subplot
function plotsize = find_plot_size(len)
    
    height = round(sqrt(len));
    width = ceil(len/height);
    plotsize = [height; width];
    
end

end