% summary: takes a folder of mono .wav files and makes them
% stereo .wav files in a new folder.
% input: pathname
% output: a series of files in a new folder that are stereo versions
function stereoize(pathname)

files = dir(strcat(pathname,'*.wav'));
mkdir(pathname,'stereo');

for i = 1 : numel(files)
    file = files(i).name;
    strcat(pathname,file);
    [y, Fs, Ndepth] = wavread(strcat(pathname,file));
    new_y = zeros(length(y),2);
    new_y(:,1) = y;
    strcat(pathname, 'stereo\', file);
    wavwrite(new_y, Fs, Ndepth, strcat(pathname, 'stereo\', file));
end

end