% analyze_hint.m
% [SNR, stdev, list] = analyze_hint(subjname, subjnum, HAnum, NCstudynum)
%
% Purpose: Return SNR, stdev, and list # for a given subject file.
%
% Input: subjname (string), subjnum (string), HAnum (string), NCstudynum (1
% or 2)
%
% Output: SNR (double), stdev (double), list (string)
function [SNR, stdev, list] = analyze_hint(subjname, subjnum, HAnum, NCstudynum)

nzlevel = 65;  % noise programmed at 65 dB(A) in the experiment

[a b c d] = read_data_file();
[SNR,stdev] = calc_SNR(d);
list = a(1);

    function [a b c d] = read_data_file()
        
        curpath = mfilename('fullpath');
        curmfile = mfilename();
        curpath = curpath(1:(end-length(curmfile)));

        filename = strcat(curpath, 'Data\', subjname, subjnum, HAnum, '.txt');
        [a b c d] = textread(filename, '%n %s %s %n');       
    
    end


    function [SNR,stdev] = calc_SNR(d)
        
        if NCstudynum == 1
            d = d(end-15:end);
        elseif NCstudynum == 2
            d = d(end-35:end);
        else
            error('Please enter a valid NCstudynum: 1 or 2.')
        end
        
        SNR = mean(d) - nzlevel;
        stdev = std(d);
        
    end


end