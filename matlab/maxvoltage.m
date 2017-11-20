
% --- Determine maximum voltage in a folder containing .wav files.
% --- Works with both mono and stereo .wav's.
% folder - a char array specifying the folder to search
% vmax - the maximum voltage
% fname - the file name with the maximum voltage
function [vmax, fname] = maxvoltage(folder)

curfolder = cd(folder);

vmax = 0;
newmax = 0;
fname = '';

files = dir('*.wav');
filenames = cell(length(files),1);

% create folder of file names
for i = 1:length(filenames)
    filenames{i} = files(i).name;
end

% loop through files, determine max
for i = 1:length(filenames)
    [y,Fs,depth] = wavread(filenames{i});
    newmax = max(max(y));
    if (newmax > vmax)
        vmax = newmax;
        fname = filenames{i};
    end
end

cd(curfolder);

end