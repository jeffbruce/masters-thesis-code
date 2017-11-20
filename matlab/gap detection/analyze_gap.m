% analyze_gap.m
%
% [gap, thresholds, stdevs, avthr, avstd] = analyze_gap(subjname, subjnum, 
% HAnum)
%
% Takes as input a subj name (arg1), subj number (arg2) , and HAnum (arg3) 
% of type string, parses the subject data file corresponding to that subj 
% name, subj & HA nums, then returns the gap threshold for each block, the
% average threshold, and standard deviations.
%
% Input: subjname (string), subjnum (string), and HAnum (string)
%
% Output: gap, thresholds, stdevs, avthr, avstd
function [gap, thresholds, stdevs, avthr, avstd] = analyze_gap(subjname, subjnum, HAnum)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

gap = zeros(8,3);
thresholds = zeros(3,1);
stdevs = zeros(3,1);

for i = 1:3

    filename = strcat(curpath, 'data\', num2str(i), subjname, subjnum, HAnum, '.txt');
    [a b c d e f] = textread(filename, '%n %n %n %n %n %n', 'headerlines', 1);
    M = [a b c d e f];
    
    Msize = size(M);
    thresh = 0;
    cur_rev = 0;
    
    for j = 1:Msize(1)
        new_rev = M(j,6);
        if new_rev ~= cur_rev
            cur_rev = new_rev;
            if cur_rev > 4
                thresh = thresh + M(j,1);
                gap(cur_rev-4,i) = M(j,1);
            end
        end
    end
    
    gap(8,i) = round(M(Msize(1),1)*(1/1.2));
    thresh = thresh + gap(8,i); 
    thresh = thresh/8;  % threshold is average of the last 8 reversals
    
    thresholds(i) = thresh;
    stdevs(i) = std(gap(:,i));
    
end

gsize = size(gap);
columngap = reshape(gap, gsize(1)*gsize(2), 1);
avthr = mean(thresholds);
avstd = std(columngap);

end