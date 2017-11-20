% produce_loc_laser_data.m
% [all_data] = produce_loc_laser_data(subjfile)
%
% Batch processes a folder of .txt files containing data on the loc laser
% task.  It does so by running analyze_loc_laser.m on each of the subject
% files, then concatenating all_data for each subject into one giant data 
% set, and writing to an Excel file.
%
% input: subjfile (arg1) (a filename specifying the names & numbers of the subjects to analyze, one per line), 
%        cond (arg2) (specifies whether to plot error by condition low/high/phone, or speaker number)
%        
% output: an Excel file listing every trial for every subject
function [alldata] = produce_loc_laser_data(subjfile)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, subjfile);
[sf] = textread(filename, '%s');
subjects = [sf];
alldata = zeros(length(subjects)*168,5);

for i=1:length(subjects)
    
    subject = subjects{i};
    subjname = subject(1:end-2);
    HAnum = subject(end-1:end);
    subjectdata = zeros(168,5);

    [lowfreq,highfreq,phone,avgerror,ovrerror] = analyze_loc_laser(subjname, HAnum, 0);
    subjectdata = [lowfreq; highfreq; phone];
    alldata((i-1)*168+1:i*168,:) = subjectdata;
    
end

output_dest = strcat(curpath, 'loc_laser_data.xls');
xlswrite(output_dest, alldata);

end