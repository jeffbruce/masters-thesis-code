% analyze_loc_laser_folder.m
% [all_data] = analyze_loc_laser_folder(subjfile,cond)
%
% Batch processes a folder of .txt files containing data on the loc laser
% task.  Does so by running analyze_loc_laser.m on each of the subject
% files, then summarizing the data in an Excel file.
%
% input: subjfile (arg1) (a filename specifying the names & numbers of the subjects to analyze, one per line), 
%        cond (arg2) (specifies whether to plot error by condition low/high/phone, or speaker number)
%        to plot error by condition: cond == 1, 
%        to plot error by speaker number: cond ~= 1
% 
% output: an Excel file listing subject number, name, overall error
function [all_data] = analyze_loc_laser_folder(subjfile,cond)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile);
[sf] = textread(filename, '%s');
subjects = [sf];

count = 1;
if cond == 1
    all_data = cell(length(subjects)+1,6);
    create_headers();
else  % cond ~= 1
    all_data = cell(length(subjects)+1,9);
    create_headers_2();
end

for i=1:length(subjects)
    
    subject = subjects{i};
    subjname = subject(1:end-2);
    HAnum = subject(end-1:end);

    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(subjname, HAnum, 0);

    all_data{i+1,1} = subject;
    all_data{i+1,2} = strcat('s',num2str(i));
    if cond == 1
        all_data{i+1,3} = ovrerror(1);
        all_data{i+1,4} = ovrerror(2);
        all_data{i+1,5} = ovrerror(3);
        all_data{i+1,6} = mean(ovrerror);
    else  % cond ~= 1
        speaker_avg = mean(avgerror,2);
        all_data{i+1,3} = speaker_avg(1);
        all_data{i+1,4} = speaker_avg(2);
        all_data{i+1,5} = speaker_avg(3);
        all_data{i+1,6} = speaker_avg(4);
        all_data{i+1,7} = speaker_avg(5);
        all_data{i+1,8} = speaker_avg(6);
        all_data{i+1,9} = speaker_avg(7);
    end
    
end

output_dest = strcat(curpath, 'loc_summary_data.xls');
xlswrite(output_dest, all_data);

    function create_headers()
        all_data{1,1} = 'name';
        all_data{1,2} = 'num';
        all_data{1,3} = 'low';
        all_data{1,4} = 'high';
        all_data{1,5} = 'phone';
        all_data{1,6} = 'avgerror';
    end

    function create_headers_2()
        all_data{1,1} = 'name';
        all_data{1,2} = 'num';
        all_data{1,3} = 'spk1';
        all_data{1,4} = 'spk2';
        all_data{1,5} = 'spk3';
        all_data{1,6} = 'spk4';
        all_data{1,7} = 'spk5';
        all_data{1,8} = 'spk6';
        all_data{1,9} = 'spk7';
    end

end