% summary: constructs an array of strings referencing .wav files.
function [newfilecell, bab, Fs, depth] = init_vcv()

% change this directory when in lab
cd('C:\Users\user\Documents\MATLAB\Neuro-Compensator\vcv\stim\');

% get all .wav filenames in the directories
filenames_b = dir('b\*.wav');
filenames_ch = dir('ch\*.wav');
filenames_d = dir('d\*.wav');
filenames_f = dir('f\*.wav');
filenames_g = dir('g\*.wav');
filenames_h = dir('h\*.wav');
filenames_k = dir('k\*.wav');
filenames_l = dir('l\*.wav');
filenames_m = dir('m\*.wav');
filenames_n = dir('n\*.wav');
filenames_p = dir('p\*.wav');
filenames_r = dir('r\*.wav');
filenames_s = dir('s\*.wav');
filenames_sh = dir('sh\*.wav');
filenames_t = dir('t\*.wav');
filenames_th = dir('th\*.wav');
filenames_v = dir('v\*.wav');
filenames_w = dir('w\*.wav');
filenames_y = dir('y\*.wav');
filenames_z = dir('z\*.wav');
filenames_zh = dir('zh\*.wav');

% create structure to store (filename, SNR)
filecell = cell(length(filenames_b)*21*2,2);
for i = 1:6
    str = filenames_b(i).name;
    filecell{i,1} = str;
    filecell{i+126,1} = str;
    str = filenames_ch(i).name;
    filecell{i+6,1} = str;
    filecell{i+132,1} = str;
    str = filenames_d(i).name;
    filecell{i+12,1} = str;
    filecell{i+138,1} = str;
    str = filenames_f(i).name;
    filecell{i+18,1} = str;
    filecell{i+144,1} = str;
    str = filenames_g(i).name;
    filecell{i+24,1} = str;
    filecell{i+150,1} = str;
    str = filenames_h(i).name;
    filecell{i+30,1} = str;
    filecell{i+156,1} = str;
    str = filenames_k(i).name;
    filecell{i+36,1} = str;
    filecell{i+162,1} = str;
    str = filenames_l(i).name;
    filecell{i+42,1} = str;
    filecell{i+168,1} = str;
    str = filenames_m(i).name;
    filecell{i+48,1} = str;
    filecell{i+174,1} = str;
    str = filenames_n(i).name;
    filecell{i+54,1} = str;
    filecell{i+180,1} = str;
    str = filenames_p(i).name;
    filecell{i+60,1} = str;
    filecell{i+186,1} = str;
    str = filenames_r(i).name;
    filecell{i+66,1} = str;
    filecell{i+192,1} = str;
    str = filenames_s(i).name;
    filecell{i+72,1} = str;
    filecell{i+198,1} = str;
    str = filenames_sh(i).name;
    filecell{i+78,1} = str;
    filecell{i+204,1} = str;
    str = filenames_t(i).name;
    filecell{i+84,1} = str;
    filecell{i+210,1} = str;
    str = filenames_th(i).name;
    filecell{i+90,1} = str;
    filecell{i+216,1} = str;
    str = filenames_v(i).name;
    filecell{i+96,1} = str;
    filecell{i+222,1} = str;
    str = filenames_w(i).name;
    filecell{i+102,1} = str;
    filecell{i+228,1} = str;
    str = filenames_y(i).name;
    filecell{i+108,1} = str;
    filecell{i+234,1} = str;
    str = filenames_z(i).name;
    filecell{i+114,1} = str;
    filecell{i+240,1} = str;
    str = filenames_zh(i).name;
    filecell{i+120,1} = str;
    filecell{i+246,1} = str;
end

% set SNR levels (+5, infinity)
for i = 1:126
    filecell{i,2} = 5;
    filecell{i+126,2} = 1000;
end

% create 6 blocks, each block contains 1 presentation of each word at 2
% SNR levels; total = 42 presentations per block (1speak*2SNR*21words)
rpcell = cell(42,1);
for i = 1:42
    rp = randperm(length(filenames_b));
    rpcell{i} = rp;
end

newfilecell = cell(length(filenames_b)*21*2,2);
for i = 1:6
    for j = 1:21
        for k = 1:2  
            newfilecell(42*(i-1)+j,k) = filecell((j-1)*6 + rpcell{j}(i),k);
            newfilecell(42*(i-1)+j+21,k) = filecell((j-1+21)*6 + rpcell{j+21}(i),k);
        end
    end
end

% randomize each block
for i = 1:6
    rp = randperm(42);
    filecell(42*(i-1)+1:42*i,1) = newfilecell(42*(i-1)+rp,1);
    filecell(42*(i-1)+1:42*i,2) = newfilecell(42*(i-1)+rp,2);
end

newfilecell = filecell;

cd ..;
cd ..;
cd ..;

% change the noise source when in lab
[bab,Fs,depth] = wavread('C:\Users\user\Documents\MATLAB\Neuro-Compensator\vcv\noise\babble16000.wav');

end