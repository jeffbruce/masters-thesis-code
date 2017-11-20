% output a matrix into a .dat file to be used with FIX
% WTF!  BEWARE: cannot use FIX on a filename exceeding a certain number of
% characters apparently.
outputfile = 'Shirlie.dat';

fcn_name = mfilename();
fullpath = mfilename('fullpath');
shortpath = fullpath(1:end-length(fcn_name));
fn = strcat(shortpath,'FIXdata\',outputfile);

labels = {'b' 'ch' 'd' 'f' 'g' 'h' 'k' 'l' 'm' 'n' 'p' 'r' 's' 'sh' 't' 'th' 'v' 'w' 'y' 'z' 'zh'};
dlmwrite(fn,1);
xlswrite(fn,labels);
dlmwrite(fn,C3,'-append','delimiter','\t','newline','pc');
%save fn labels -ASCII -TABS
%save fn C3 -ASCII -TABS -APPEND