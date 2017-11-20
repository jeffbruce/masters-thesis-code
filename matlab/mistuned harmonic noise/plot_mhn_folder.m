% plot_mhn_folder.m
% [alldata] = plot_mhn_folder('all_subjects_3')
%
% plots a graph for each condition for each subject, and also outputs the 
% raw data to a summary file called mhn_summary_data.xls.
%
% input: subjfile (a filename specifying the names & numbers of the subjects to analyze, one per line)
%
% output: h graphs displaying threshold and stdev, where h=num of harmonics
function [all_data] = plot_mhn_folder(subjfile)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile, '.txt');
[subjects] = textread(filename, '%s');
n = length(subjects)/2;

all_data = cell(2*n+1,7);
all_thresholds = zeros(2*n,2);
all_stdevs = zeros(2*n,2);
create_headers();

for i=1:2*n
    
    subject = subjects{i};
    subjname = subject(1:end-2);
    HAnum = subject(end-1:end);
        
    [mhn,thresholds,stdevs] = analyze_mhnoise(subjname, HAnum);
    
    all_thresholds(i,1) = thresholds(1);
    all_thresholds(i,2) = thresholds(2);
    all_stdevs(i,1) = stdevs(1);
    all_stdevs(i,2) = stdevs(2);
    
    all_data{i+1,1} = subjname;
    all_data{i+1,2} = HAnum;
    all_data{i+1,3} = thresholds(1);
    all_data{i+1,4} = thresholds(2);
    all_data{i+1,5} = stdevs(1);
    all_data{i+1,6} = stdevs(2);
    if i < n+1
        all_data{i+1,7} = 'NC';
    else
        all_data{i+1,7} = 'WDRC';
    end
    
end

all_thresholds = (all_thresholds-1)*100;
all_stdevs = all_stdevs*100;

output_dest = strcat(curpath, 'mhn_summary_data.xls');
xlswrite(output_dest, all_data);

plot_thresholds(1)
plot_thresholds(2)


    % plots speaker/response confusion matrix
    function plot_thresholds(c)

        figure(c);
        barerrorbar(all_thresholds(:,c), all_stdevs(:,c)); 
        if c == 1
            title('200Hz Mistuned Harm Thresholds (3rd harmonic) - Individuals','FontSize',14);
        elseif c == 2
            title('600Hz Mistuned Harm Thresholds (3rd harmonic) - Individuals','FontSize',14);
        end
        xlabel('Subject','FontSize',14);
        ylabel('Mistuned Threshold (%)','FontSize',14);
        set(gca,'YLim',[0 50]);
        %set(gca,'XTickLabel',create_xticklabels(subjects));

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


    function create_headers()
        all_data{1,1} = 'sname';
        all_data{1,2} = 'session';
        all_data{1,3} = '200';
        all_data{1,4} = '600';
        all_data{1,5} = '200std';
        all_data{1,6} = '600std';
        all_data{1,7} = 'HA';
    end

end