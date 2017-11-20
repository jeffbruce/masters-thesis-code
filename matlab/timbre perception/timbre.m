%{ 
summary: runs the timbre perception experiment
2AFC, sax with 5 altered partials, tenor saxophone
      altered partials by removing it completely
%}

cd('C:\Users\Jeff\Documents\McMaster University\Neuro-Compensator Research\Music Perception\Timbre Perception\Stimuli\');

rand('seed', sum(100*clock()));

% open file for data to be written to
subjname = input('Input subject name: ', 's');
fileID = fopen(strcat(subjname,'.txt'), 'wt');
fprintf(fileID, 'harm\tresp\tcor?\n');

% create stimuli
[std, Fs] = wavread('271\271TSNOM-17');
newstd = zeros(Fs,1);
newstd(1:length(std)) = std;
std = newstd;
samp1 = wavread('271\271TSNOM-17-250rem');
samp2 = wavread('271\271TSNOM-17-500rem');
samp3 = wavread('271\271TSNOM-17-750rem');
samp4 = wavread('271\271TSNOM-17-1050rem');
samp5 = wavread('271\271TSNOM-17-1300rem');

stim1_1 = zeros(Fs*3, 1);
stim1_2 = zeros(Fs*3, 1);
stim2_1 = zeros(Fs*3, 1);
stim2_2 = zeros(Fs*3, 1);
stim3_1 = zeros(Fs*3, 1);
stim3_2 = zeros(Fs*3, 1);
stim4_1 = zeros(Fs*3, 1);
stim4_2 = zeros(Fs*3, 1);
stim5_1 = zeros(Fs*3, 1);
stim5_2 = zeros(Fs*3, 1);

stim_same = zeros(Fs*3, 1);

stim1_1(1:Fs,1) = std;
stim1_1(Fs*2+1:3*Fs,1) = samp1;
stim1_2(1:Fs,1) = samp1;
stim1_2(Fs*2+1:3*Fs,1) = std;
stim2_1(1:Fs,1) = std;
stim2_1(Fs*2+1:3*Fs,1) = samp2;
stim2_2(1:Fs,1) = samp2;
stim2_2(Fs*2+1:3*Fs,1) = std;
stim3_1(1:Fs,1) = std;
stim3_1(Fs*2+1:3*Fs,1) = samp3;
stim3_2(1:Fs,1) = samp3;
stim3_2(Fs*2+1:3*Fs,1) = std;
stim4_1(1:Fs,1) = std;
stim4_1(Fs*2+1:3*Fs,1) = samp4;
stim4_2(1:Fs,1) = samp4;
stim4_2(Fs*2+1:3*Fs,1) = std;
stim5_1(1:Fs,1) = std;
stim5_1(Fs*2+1:3*Fs,1) = samp5;
stim5_2(1:Fs,1) = samp5;
stim5_2(Fs*2+1:3*Fs,1) = std;

stim_same(1:Fs,1) = std;
stim_same(Fs*2+1:3*Fs,1) = std;

ordered_stim = cell(100,3);

for i = 1:5
    ordered_stim{i,1} = stim1_1;
    ordered_stim{i+5,1} = stim1_2;
    ordered_stim{i,3} = 1;
    ordered_stim{i+5,3} = 1;
    ordered_stim{i+10,1} = stim2_1;
    ordered_stim{i+15,1} = stim2_2;
    ordered_stim{i+10,3} = 2;
    ordered_stim{i+15,3} = 2;
    ordered_stim{i+20,1} = stim3_1;
    ordered_stim{i+25,1} = stim3_2;
    ordered_stim{i+20,3} = 3;
    ordered_stim{i+25,3} = 3;
    ordered_stim{i+30,1} = stim4_1;
    ordered_stim{i+35,1} = stim4_2;
    ordered_stim{i+30,3} = 4;
    ordered_stim{i+35,3} = 4;
    ordered_stim{i+40,1} = stim5_1;
    ordered_stim{i+45,1} = stim5_2;
    ordered_stim{i+40,3} = 5;
    ordered_stim{i+45,3} = 5;
end

for i = 1:50
    ordered_stim{i,2} = 2;
end

for i = 51:100
    ordered_stim{i,1} = stim_same;
    ordered_stim{i,2} = 1;
    ordered_stim{i,3} = -1;  % same trials
end

rp = randperm(length(ordered_stim));
rand_stim = ordered_stim(rp,:);

for i = 1:100
   
    sound(rand_stim{i}, Fs);
    
    resp = input('Input response, 1 (same) or 2 (diff): ','s');
    
    if (str2num(resp) == rand_stim{i,2})
        str = 'correct';
    else
        str = 'incorrect';
    end
    
    fprintf(fileID, strcat(num2str(rand_stim{i,3}), ['\t', resp], ['\t', str],'\n'));
    
end
