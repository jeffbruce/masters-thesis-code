% analyze_timbre_noise.m
%
% [timbre, thresholds, stdevs] = analyze_timbre_noise(subjname, subjnum,
% HAnum)
%
% Takes as input a subject name (arg1), subject number (arg2), and HAnum 
% (arg3) of type string, parses the subject data file corresponding to that 
% subject name and number, then returns the timbre threshold (% detectable 
% intensity change) for each block, the average timbre threshold, and 
% standard deviations.
%
% Input: subjname (string), subjnum (string), and HAnum (string)
%
% Output: timbre (raw data), thresholds (overall), stdevs (overall)
function [timbre, thresholds, stdevs] = analyze_timbre_noise(subjname, subjnum, HAnum)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

% this block gets all files that refer to <subjname, subjnum, HAnum>
allfiles = dir(strcat(curpath,'data\'));
fileindices = [];
for i = 1:length(allfiles)
    fn = allfiles(i).name;
    if ~isempty(findstr(fn,strcat(subjname, subjnum, HAnum)))
        fileindices(end+1) = i;
    end
end
    
% list harmonic# in first row
timbre = zeros(9,length(fileindices));
thresholds = zeros(length(fileindices),1);
stdevs = zeros(length(fileindices),1);
tfactor = [0.2 0.05 0.15];
maxdB = [25.2905 25.2905 25.2905];
mindB = [22.9741 24.8274 23.7745];

for i = 1:length(fileindices)

    filename = strcat(curpath, 'data\', allfiles(fileindices(i)).name);
    harmnum = str2num(allfiles(fileindices(i)).name(1));
    
    timbre(1,i) = harmnum;
    
    [a1 a2 a3 a4 a5 a6 a7 a8 a9] = textread(filename, '%n %n %n %n %n %n %n %n %s', 'headerlines', 1);
    M = [a1 a2 a3 a4 a5 a6];
    
    Msize = size(M);
    thresh = 0;
    cur_rev = 0;
    
    for j = 1:Msize(1)
        new_rev = M(j,2);
        if new_rev ~= cur_rev
            cur_rev = new_rev;
            if cur_rev > 4
                thresh = thresh + M(j,5);
                timbre(cur_rev-3,i) = M(j,5);
            end
        end
    end
     
    timbre(9,i) = M(Msize(1),5) + tfactor(harmnum);
    thresh = thresh + timbre(9,i);
    thresh = thresh/8;  % get average detectable power
    % express minimum detectable intensity as %
    thresh = (maxdB(harmnum) - thresh) / (maxdB(harmnum) - mindB(harmnum));
    
    thresholds(i) = thresh;
    stdevs(i) = std(timbre(2:9,i));
    
end

%mhsize = size(mhn);
%columnmh = reshape(mhn, mhsize(1)*mhsize(2), 1);

end