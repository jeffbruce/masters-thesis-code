% plot_loc_laser_folder_within.m
%
% summary: similar to plot_loc_laser_folder.m, but instead of supplying a
%       .txt file with 1 list of names, there are two columns.  the first 
%       column is NC data, the second column is WDRC data.
%
% input: subjfile (filename specifying the filenames of NC and WDRC data)
%       by default this file is called all_subjects_within.txt, but you 
%       leave out the .txt extension when calling this function.
%
% output: a plot of responses/errors per condition
function plot_loc_laser_folder_within(subjfile)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile, '.txt');
[NC WDRC] = textread(filename, '%s %s');
NCsubs = NC;
WDRCsubs = WDRC;
plotsize = find_plot_size(length(NCsubs));

%specify titles for graph
graph_titles = [NCsubs; WDRCsubs];
subjects = [NCsubs; WDRCsubs];

figure(1);  % SPEAKER RESPONSE MATRIX FOR EACH PARTICIPANT
for i=1:length(NCsubs)
    
    NCsub = NCsubs{i};
    WDRCsub = WDRCsubs{i};
    NCsubname = NCsub(1:end-2);
    WDRCsubname = WDRCsub(1:end-2);
    NCHAnum = NCsub(end-1:end);
    WDRCHAnum = WDRCsub(end-1:end); 
    
    % supply a 0 as an argument to suppress any plots in analyze_loc_laser
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(NCsubname, NCHAnum, 0);
    alldata = [lowfreq;highfreq;phone];
    subplot(plotsize(1),plotsize(2),i);
    plot_responses(i);
    
    % supply a 0 as an argument to suppress any plots in analyze_loc_laser
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(WDRCsubname, WDRCHAnum, 0);
    alldata = [lowfreq;highfreq;phone];
    subplot(plotsize(1),plotsize(2),i+length(WDRCsubs));
    plot_responses(i+length(WDRCsubs));
    
end

figure(2);  % SPEAKER AVGERROR MATRIX FOR EACH PARTICIPANT
for i=1:length(NCsubs)
   
    NCsub = NCsubs{i};
    WDRCsub = WDRCsubs{i};
    NCsubname = NCsub(1:end-2);
    WDRCsubname = WDRCsub(1:end-2);
    NCHAnum = NCsub(end-1:end);
    WDRCHAnum = WDRCsub(end-1:end); 
    
    % supply a 0 as an argument to suppress any plots in analyze_loc_laser
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(NCsubname, NCHAnum, 0);
    alldata = [lowfreq;highfreq;phone];
    subplot(plotsize(1),plotsize(2),i);
    plot_errors(i);
    
    % supply a 0 as an argument to suppress any plots in analyze_loc_laser
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(WDRCsubname, WDRCHAnum, 0);
    alldata = [lowfreq;highfreq;phone];
    subplot(plotsize(1),plotsize(2),i+length(WDRCsubs));
    plot_errors(i+length(WDRCsubs));
    
end

figure(3);  % SPEAKER AVGERROR MATRIX FOR EACH PARTICIPANT*CONDITION
for i=1:length(NCsubs)

    NCsub = NCsubs{i};
    WDRCsub = WDRCsubs{i};
    NCsubname = NCsub(1:end-2);
    WDRCsubname = WDRCsub(1:end-2);
    NCHAnum = NCsub(end-1:end);
    WDRCHAnum = WDRCsub(end-1:end); 
    
    % supply a 0 as an argument to suppress any plots in analyze_loc_laser
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(NCsubname, NCHAnum, 0);
    alldata = [lowfreq;highfreq;phone];
    subplot(plotsize(1),plotsize(2),i);
    plot_errors_by_cond(i);
    
    % supply a 0 as an argument to suppress any plots in analyze_loc_laser
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(WDRCsubname, WDRCHAnum, 0);
    alldata = [lowfreq;highfreq;phone];
    subplot(plotsize(1),plotsize(2),i+length(WDRCsubs));
    plot_errors_by_cond(i+length(WDRCsubs));

end
legend('low','high','phone');

figure(4);  % RESPONSES/ERRORS/ERRORS BY CONDITION ALL ON ONE PLOT
for i=1:length(subjects)

    subject = subjects{i};
    subjname = subject(1:end-2);
    subjnum = subject(end-1:end);

    % supply a 0 as an argument to suppress any plots in analyze_loc
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(subjname, subjnum, 0);
    alldata = [lowfreq;highfreq;phone];

    subplot(3,length(subjects),i);
    plot_responses(i);
    subplot(3,length(subjects),length(subjects)+i);
    plot_errors(i);
    subplot(3,length(subjects),2*length(subjects)+i);
    plot_errors_by_cond(i);

end
legend('low','high','phone');
    
% plots speaker/error by participant*condition
function plot_errors_by_cond(id)
    hold on
    h = bar(avgerror); 
    %scatter(alldata(:,3)*15 - 15, alldata(:,5),'r');
    title(graph_titles{id},'FontSize',14);
    xlabel('speaker number','FontSize',14);
    ylabel('error (°)','FontSize',14);
    set(gca,'YLim',[0 45]);
    set(gca,'XTick',[1:7])
    hold off
end

% plots speaker/error by participant
function plot_errors(id)
    mult = [1/3; 1/3; 1/3];
    speakeravg = avgerror*mult;
    hold on
    bar(0:15:90, speakeravg); 
    scatter(alldata(:,3)*15 - 15, alldata(:,5),'r');
    axis([0 90 0 90]);
    title(graph_titles{id},'FontSize',14);
    xlabel('stimulus (°)','FontSize',14);
    ylabel('error (°)','FontSize',14);
    hold off
end

% plots speaker/response by participant
function plot_responses(id)
    
    responseavg = zeros(7,1);
    for j=1:7
        indices = find(alldata(:,3)==j);
        responseavg(j) = mean(alldata(indices,4));
    end
    
    hold on
    bar(0:15:90, responseavg); 
    scatter(alldata(:,3)*15 - 15, alldata(:,4),'r');
    axis([0 90 0 90]);
    title(graph_titles{id},'FontSize',14);
    xlabel('stimulus (°)','FontSize',14);
    ylabel('response (°)','FontSize',14);
    hold off
end

% calculates optimal size for subplot
function plotsize = find_plot_size(len)
    
    height = 2;
    width = len;
    plotsize = [height; width];
    
end


end