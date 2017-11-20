% analyze_mhnoise.m
%
% Takes as input a subject name (arg1) and subject number (arg2) of type 
% string, parses the subject data file corresponding to that subject name
% and number, then returns the mistuned harmonic threshold for each block, 
% the average harmonic threshold, and standard deviations.
%
% input: subject name and subject number as strings
%
% output: mhn, thresholds, stdevs
function [mhn, thresholds, stdevs] = analyze_mhnoise(subjname, subjnum)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

% this block gets all files that refer to <subjname, subjnum>
allfiles = dir(strcat(curpath,'data\'));
fileindices = [];
for i = 1:length(allfiles)
    fn = allfiles(i).name;
    if ~isempty(findstr(fn,strcat(subjname, subjnum)))
        fileindices(end+1) = i;
    end
end
    
% list freq and harm in first 2 rows
mhn = zeros(10,length(fileindices));
thresholds = zeros(length(fileindices),1);
stdevs = zeros(length(fileindices),1);

for i = 1:length(fileindices)

    filename = strcat(curpath, 'data\', allfiles(fileindices(i)).name);
    
    hyphind = findstr(allfiles(fileindices(i)).name,'-');
    subjnameind = findstr(allfiles(fileindices(i)).name,subjname);
    harm = allfiles(fileindices(i)).name(hyphind+1:subjnameind-1);
    freq = allfiles(fileindices(i)).name(1:hyphind-1);
    mhn(1,i) = str2num(freq);
    mhn(2,i) = str2num(harm);
    
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
                mhn(cur_rev-2,i) = M(j,5);
            end
        end
    end
    
    factor = (M(Msize(1),5) - 1)*0.4; 
    mhn(10,i) = M(Msize(1),5) - factor;
    thresh = thresh + mhn(10,i);
    thresh = thresh/8;  % threshold is average of the last 8 reversals
    
    thresholds(i) = thresh;
    stdevs(i) = std(mhn(3:10,i));
    
end

mhsize = size(mhn);
%columnmh = reshape(mhn, mhsize(1)*mhsize(2), 1);

end