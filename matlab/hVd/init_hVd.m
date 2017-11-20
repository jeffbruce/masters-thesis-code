% summary: constructs an array of strings referencing .wav files.
function [newfilecell, bab, Fs, depth] = init_hVd()

% change this directory when in lab
cd('C:\Users\user\Documents\MATLAB\Neuro-Compensator\hVd\stim\');

% get all .wav filenames in the directories
filenames_ae = dir('ae\*.wav');
filenames_aw = dir('aw\*.wav');
filenames_eh = dir('eh\*.wav');
filenames_ei = dir('ei\*.wav');
filenames_er = dir('er\*.wav');
filenames_ih = dir('ih\*.wav');
filenames_iy = dir('iy\*.wav');
filenames_oa = dir('oa\*.wav');
filenames_oo = dir('oo\*.wav');
filenames_uh = dir('uh\*.wav');
filenames_uw = dir('uw\*.wav');

% create structure to store (filename, SNR)
filecell = cell(length(filenames_ae)*11*2,2);
for i = 1:10
    str = filenames_ae(i).name;
    filecell{i,1} = str;
    filecell{i+110,1} = str;
    str = filenames_aw(i).name;
    filecell{i+10,1} = str;
    filecell{i+120,1} = str;
    str = filenames_eh(i).name;
    filecell{i+20,1} = str;
    filecell{i+130,1} = str;
    str = filenames_ei(i).name;
    filecell{i+30,1} = str;
    filecell{i+140,1} = str;
    str = filenames_er(i).name;
    filecell{i+40,1} = str;
    filecell{i+150,1} = str;
    str = filenames_ih(i).name;
    filecell{i+50,1} = str;
    filecell{i+160,1} = str;
    str = filenames_iy(i).name;
    filecell{i+60,1} = str;
    filecell{i+170,1} = str;
    str = filenames_oa(i).name;
    filecell{i+70,1} = str;
    filecell{i+180,1} = str;
    str = filenames_oo(i).name;
    filecell{i+80,1} = str;
    filecell{i+190,1} = str;
    str = filenames_uh(i).name;
    filecell{i+90,1} = str;
    filecell{i+200,1} = str;
    str = filenames_uw(i).name;
    filecell{i+100,1} = str;
    filecell{i+210,1} = str;
end

% set SNR levels (+5, infinity)
for i = 1:110
    filecell{i,2} = 5;
    filecell{i+110,2} = 1000;
end

% create 5 blocks, each block contains 2 presentations of each word at 2
% SNR levels; total = 44 presentations per block (2speak*2SNR*11words)
rpcell = cell(22,1);
for i = 1:22
    rp = randperm(length(filenames_ae));
    rpcell{i} = rp;
end

newfilecell = cell(length(filenames_ae)*11*2,2);
for i = 1:5
    for j = 1:11
        for k = 1:2  
            newfilecell(44*(i-1)+4*(j-1)+1,k) = filecell((j-1)*10 + rpcell{j}(2*i-1),k);
            newfilecell(44*(i-1)+4*(j-1)+2,k) = filecell((j-1)*10 + rpcell{j}(2*i),k);
            newfilecell(44*(i-1)+4*(j-1)+3,k) = filecell((j-1+11)*10 + rpcell{j+11}(2*i-1),k);
            newfilecell(44*(i-1)+4*(j-1)+4,k) = filecell((j-1+11)*10 + rpcell{j+11}(2*i),k);
        end
    end
end

% randomize each block
for i = 1:5
    rp = randperm(44);
    filecell(44*(i-1)+1:44*i,1) = newfilecell(44*(i-1)+rp,1);
    filecell(44*(i-1)+1:44*i,2) = newfilecell(44*(i-1)+rp,2);
end

newfilecell = filecell;

cd ..;
cd ..;
cd ..;

% change the noise source when in lab
[bab,Fs,depth] = wavread('C:\Users\user\Documents\MATLAB\Neuro-Compensator\hVd\noise\babble16000.wav');

end