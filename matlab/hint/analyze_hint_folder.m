% analyze_hint_folder.m
% [all_data] = analyze_hint_folder(subjfile, NCstudynum)
%
% Purpose: Return SNR, stdev, and list #'s, for all subjects in subjfile. 
%
% Input: subjfile (string), NCstudynum (1 or 2)
%
% Output: all_data (cell), a collection of SNR, stdev, list, over all
%         subjects
function [all_data] = analyze_hint_folder(subjfile, NCstudynum)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile, '.txt');
[subjects] = textread(filename, '%s');
n = length(subjects)/2;

all_data = cell(2*n,5);
all_thresholds = zeros(2*n,1);
all_stdevs = zeros(2*n,1);
create_headers();

for i = 1:2*n
    
    subject = subjects{i};
    subjname = subject(1:end-4);
    subjnum = subject(end-3:end-2);
    HAnum = subject(end-1:end);
    [SNR, stdev, list] = analyze_hint(subjname, subjnum, HAnum, NCstudynum);
    
    all_thresholds(i) = SNR;
    all_stdevs(i) = stdev;
    
    all_data{i+1,1} = subjnum;
    all_data{i+1,3} = SNR;
    all_data{i+1,4} = stdev;
    all_data{i+1,5} = list;
    
end

all_data
output_dest = strcat(curpath, 'hint_summary_data.xls');
xlswrite(output_dest, all_data);
plot_thresholds();



    % plots hint thresholds for each participant
    function plot_thresholds()

        figure(1);
        barerrorbar(all_thresholds, all_stdevs); 
        title('HINT Scores','FontSize',14);
        xlabel('Subjects','FontSize',14);
        ylabel('Signal-to-Noise Ratio (SNR)','FontSize',14);
        set(gca,'YLim',[-10 10]);
        set(gca,'XTickLabel',create_xticklabels(subjects));

    end


    function create_headers()
        all_data{1,1} = 'snum';
        all_data{1,2} = 'HA';
        all_data{1,3} = 'SNR';
        all_data{1,4} = 'stdev';
        all_data{1,5} = 'list';
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


end