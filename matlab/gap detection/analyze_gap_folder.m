% analyze_gap_folder.m
% [all_data] = analyze_gap_folder('all_subjects')
%
% Batch processes a folder of .txt files containing data on the gap 
% detection task.  Does so by running analyze_gap.m on each of the subject
% files, then summarizing the data in an Excel file.
%
% input: subjfile (arg1) (a filename specifying the names of the subjects to
% analyze, one per line)
%
% output: an Excel file listing subject number, name, and avg threshold
function [all_data] = analyze_gap_folder(subjfile)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile, '.txt');
[subjs] = textread(filename, '%s');
n = length(subjs)/2;

%count = 1;
all_data = cell(2*n+1,8);
all_thresholds = zeros(2*n,1);
all_stdevs = zeros(2*n,1);
create_headers();

for i=1:2*n
    
    subject = subjs{i};
    subjname = subject(1:end-4);
    subjnum = subject(end-3:end-2);
    HAnum = subject(end-1:end);
        
    [gap, thresholds, stdevs, avthr, avstd] = analyze_gap(subjname, subjnum, HAnum);
    
    all_thresholds(i) = mean(thresholds);
    all_stdevs(i) = avstd;
    
    all_data{i+1,1} = subjname;
    all_data{i+1,2} = strcat('s',subjnum);
    all_data{i+1,3} = HAnum;
    all_data{i+1,4} = thresholds(1);
    all_data{i+1,5} = thresholds(2);
    all_data{i+1,6} = thresholds(3);
    all_data{i+1,7} = avstd;
    if i < n+1
        all_data{i+1,8} = 'NC';
    else
        all_data{i+1,8} = 'WDRC';
    end
        
end

output_dest = strcat(curpath, 'gap_summary_data.xls');
xlswrite(output_dest, all_data);
plot_thresholds()


    % plots gap thresholds for each participant
    function plot_thresholds()

        figure(1);
        barerrorbar(all_thresholds, all_stdevs); 
        title('Individual Gap Detection Thresholds','FontSize',14);
        xlabel('Subjects','FontSize',14);
        ylabel('Thresholds (ms)','FontSize',14);
        set(gca,'YLim',[0 100]);
        %set(gca,'XTickLabel',create_xticklabels(subjs));

    end
    

    % turns a subject name into HA type and subject number
    % by convention, assumes the first n entries are NC, then the next n
    % entries are WDRC
    function [xticklabels] = create_xticklabels(subjects)
        
        n = length(subjects)/2;
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


    function create_headers()
        all_data{1,1} = 'sname';
        all_data{1,2} = 'snum';
        all_data{1,3} = 'session';
        all_data{1,4} = 'thresh1';
        all_data{1,5} = 'thresh2';
        all_data{1,6} = 'thresh3';
        all_data{1,7} = 'avstd';
        all_data{1,8} = 'HA';
    end


end