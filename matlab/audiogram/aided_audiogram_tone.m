function [A] = aided_audiogram_tone(side)
% done for each ear separately
% 1 for right (keep right HA on), 2 for left (keep left HA on)
% plays pure tones, obtains thresholds for each audiometric frequency

rand('seed', sum(100*clock()));

% get filepath so files can be saved to this directory automatically
entirepath = mfilename('fullpath');
filename = mfilename();
filepath = entirepath(1:end-length(filename));

% get subject name and reserve file for them
subjname = input('Input subject name and number: ', 's');
fileID = fopen(strcat('data\',subjname,'.txt'), 'wt');
fprintf(fileID, 'Hz\tdB HL\tresp\tlast\tstreak\tcur_rev\n');
figure(run_gap_detection);

Fs = 44100;
freq = 0;
y = zeros(Fs*1.5,1);
y = sin

% try each frequency, allow response
% 2 choices - was there a sound, or was there no sound?

present = round(rand(1));  % 0 for no sound, 1 for sound

for i = 1:8  % (250, 500, 1000, 2000, 3000, 4000, 6000, 8000)
    
    if i == 1
        freq = 1000;
    elseif i == 2
        freq = 2000;
    elseif i == 3
        freq = 3000;
    elseif i == 4
        freq = 4000;
    elseif i == 5
        freq = 6000;
    elseif i == 6
        freq = 8000;
    elseif i == 7
        freq = 500;
    else  % i == 8
        freq = 250;
    end
    
    while done == 0  % terminate when threshold has been reached twice
        
        y = zeros(1,1.5*Fs);
        
        for j = 0:1:(1.5*Fs-1)
            y(j+1) = sin(2*pi*j*freq/Fs);
        end
        
      
    end
        
end

end

