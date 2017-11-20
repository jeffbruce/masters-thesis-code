% plot_loc_laser_folder.m
%
% input: subjfile (a filename specifying the names & numbers of the subjects 
%        to analyze, one per line) by default this file is called 
%        all_subjects.txt, but you leave out the .txt extension when 
%        calling this function.
%
% output: a plot of responses/errors per condition
function plot_loc_laser_folder(subjfile)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile, '.txt');
[subjects] = textread(filename, '%s');
plotsize = find_plot_size(length(subjects));
n = length(subjects)/2;

%specify titles for graph
graph_titles = create_xticklabels(subjects);

figure(1);  % SPEAKER RESPONSE MATRIX FOR EACH PARTICIPANT
for i=1:2*n
    
    subject = subjects{i};
    subjname = subject(1:end-2);
    HAnum = subject(end-1:end);
        
    % supply a 0 as an argument to suppress any plots in analyze_loc_laser
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(subjname, HAnum, 0);
    alldata = [lowfreq;highfreq;phone];
    
    subplot(plotsize(1),plotsize(2),i);
    plot_responses(i);

end

figure(2);  % SPEAKER AVGERROR MATRIX FOR EACH PARTICIPANT
for i=1:2*n
    
    subject = subjects{i};
    subjname = subject(1:end-2);
    HAnum = subject(end-1:end);
        
    % supply a 0 as an argument to suppress any plots in analyze_loc
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(subjname, HAnum, 0);
    alldata = [lowfreq;highfreq;phone];
    
    subplot(plotsize(1),plotsize(2),i);
    plot_errors(i);
    
end


figure(3);  % SPEAKER AVGERROR MATRIX FOR EACH PARTICIPANT
for i=1:2*n
    
    subject = subjects{i};
    subjname = subject(1:end-2);
    HAnum = subject(end-1:end);
        
    % supply a 0 as an argument to suppress any plots in analyze_loc
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(subjname, HAnum, 0);
    alldata = [lowfreq;highfreq;phone];
    
    if i < n+1
        subplot(plotsize(1),plotsize(2),i);
        plot_errors(i);
    else
        subplot(plotsize(1),plotsize(2),i+1);
        plot_errors(i);
    end
    
end

%{
figure(3);  % SPEAKER AVGERROR MATRIX FOR EACH PARTICIPANT*CONDITION
for i=1:length(subjects)

    subject = subjects{i};
    subjname = subject(1:end-2);
    subjnum = subject(end-1:end);

    % supply a 0 as an argument to suppress any plots in analyze_loc
    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(subjname, subjnum, 0);
    alldata = [lowfreq;highfreq;phone];

    subplot(plotsize(1),plotsize(2),i);
    plot_errors_by_cond(i);

end
legend('low','high','phone');
%}

%{
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
%}  

%{
figure(5);  % SPEAKER AVGERROR MATRIX FOR EACH PARTICIPANT
for i=1:n
    
    subject = subjects{i};
    subjname = subject(1:end-2);
    HAnum = subject(end-1:end);
        
    % supply a 0 as an argument to suppress any plots in analyze_loc
    [lowfreq1,highfreq1,phone1,avgerror1,ovrerror1] = analyze_loc_laser(subjname, HAnum, 0);
    alldata1 = [lowfreq1;highfreq1;phone1];
    
    subject = subjects{i+n};
    subjname = subject(1:end-2);
    HAnum = subject(end-1:end);
    
    % supply a 0 as an argument to suppress any plots in analyze_loc
    [lowfreq2,highfreq2,phone2,avgerror2,ovrerror2] = analyze_loc_laser(subjname, HAnum, 0);
    alldata2 = [lowfreq2;highfreq2;phone2];
    
    subplot(plotsize(1),plotsize(2),i);
    plot_individ_HA_errors(i);
    
end
%}

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


    % plots speaker/error by participant for both HAs
    % DOESNT WORK
    function plot_individ_HA_errors(id)
        mult = [1/3; 1/3; 1/3];
        speakeravg1 = avgerror1*mult;
        speakeravg2 = avgerror2*mult;
        bar([speakeravg1; speakeravg2]);
        
        %scatter(alldata(:,3)*15 - 15, alldata(:,5),'r');
        title(graph_titles{id},'FontSize',14);
        xlabel('stimulus (°)','FontSize',14);
        ylabel('error (°)','FontSize',14);
        set(gca,'YLim',[0 45]);
        set(gca,'XTick',[1:7])
        hold off
    end


    % turns a subject name into HA type and subject number
    % by convention, assumes the first n entries are NC, then the next n
    % entries are WDRC
    function [xticklabels] = create_xticklabels(subjects)
        
        xticklabels = cell(2*n,1);
        
        HA = 'NC';
        for i = 1:n
            subject = subjects{i};
            subjnum = subject(end-3:end-2);
            xticklabels{i} = strcat(HA,subjnum);
        end
        
        HA = 'WDRC';
        for i = n+1:2*n
            subject = subjects{i};
            subjnum = subject(end-3:end-2);
            xticklabels{i} = strcat(HA,subjnum);
        end
            
    end


    % calculates optimal size for subplot
    function plotsize = find_plot_size(len)

        height = ceil(sqrt(len));
        width = ceil(len/height);
        plotsize = [height; width];

    end


end