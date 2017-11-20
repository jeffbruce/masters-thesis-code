% analyze_wd.m
% [list1cor,list2cor] = analyze_wd(subjname, subjnum, HAnum)
%
% Purpose: Return %cor for list 1 & 2 for each subject in subjfile. 
%
% Input: subjname (string), subjnum (string), HAnum (string)
%
% Output: list1cor, list2cor, %cor for each list
function [list1cor,list2cor] = analyze_wd(subjname, subjnum, HAnum)

curpath = mfilename('fullpath');
curmfile = mfilename();
curpath = curpath(1:(end-length(curmfile)));

filename = strcat(curpath, strcat('data\',subjname,subjnum,HAnum,'.txt'));
[a b] = textread(filename, '%n %n', 'headerlines', 1);
list1cor = length(find(b(1:49)==1));
list1cor = list1cor/49*100;
list2cor = length(find(b(50:99)==1));
list2cor = list2cor/50*100;

end