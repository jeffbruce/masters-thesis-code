function testrampsize()

% sample rate
Fs = 44100;
Nf = Fs/2;
ISI = 500;

% stimulus parameters
freq = 1000;
duration = 500;
risefall = 50;
band = 50;

% gap parameters
gap = 100;
env = 0;

% CREATE GAP STIM

% create 1000 Hz noise with 50 Hz bandwidth
whitenz = wgn(1, duration/1000*Fs, 1);  %500ms duration
B = fir1(1000,[(freq-band/2)/Nf, (freq+band/2)/Nf], hanning(1001));
y = convn(whitenz,B,'same');  % create filtered signal

% apply 50ms rise and fall
y(1:(risefall/1000*Fs)) = sin([0:((risefall/1000*Fs)-1)]*pi/4410).*y(1:(risefall/1000*Fs));  
y(((duration/1000*Fs)-risefall/1000*Fs+1):(duration/1000*Fs)) = cos([0:((risefall/1000*Fs)-1)]*pi/4410).*y(((duration/1000*Fs)-risefall/1000*Fs+1):(duration/1000*Fs));  % apply 50ms fall


% CREATE NOTCHED BACKGROUND NOISE

backgrnd = wgn(1, duration/1000*Fs, 1);
B = fir1(1000,[(freq-band/2)/Nf, (freq+band/2)/Nf], 'stop');
backgrnd = convn(backgrnd,B,'same');  % create filtered signal

% scale background noise to make it quieter
backgrnd = backgrnd.*0.04;

% apply 50ms rise and fall
backgrnd(1:(risefall/1000*Fs)) = sin([0:((risefall/1000*Fs)-1)]*pi/4410).*backgrnd(1:(risefall/1000*Fs));  
backgrnd((((duration)/1000*Fs)-risefall/1000*Fs+1):((duration)/1000*Fs)) = cos([0:((risefall/1000*Fs)-1)]*pi/4410).*backgrnd((((duration)/1000*Fs)-risefall/1000*Fs+1):((duration)/1000*Fs));


% CREATE THE STANDARD AND DEVIANT

% create standard
t = 0:(1/Fs):(duration/1000)-(1/Fs);
standard = y;

% create deviant by cos^2 windowing the standard, then adding a gap
deviant = standard;
mdpt = round(length(standard)/2);

s = warning('off','all');

% apply cos^2 window with env (ms) duration
coef = cos([0:(1/Fs):(env/1000)-(1/Fs)]*(1000/env)*(pi/2)).^2;
deviant((mdpt - Fs*(gap/2/1000*env)):(mdpt - Fs*((gap/2)-1)/1000*env - 1)) = ...
    coef.*deviant((mdpt - Fs*(gap/2/1000*env)):(mdpt - Fs*((gap/2)-1)/1000*env - 1));

coef = sin([0:(1/Fs):(env/1000)-(1/Fs)]*(1000/env)*(pi/2)).^2;
deviant((mdpt + Fs*((gap/2)-1)/1000*env + 1):(mdpt + Fs*(gap/2/1000*env))) = ...
    coef.*deviant((mdpt + Fs*((gap/2)-1)/1000*env + 1):(mdpt + Fs*(gap/2/1000*env)));

warning(s);

% add a gap between the two windows
deviant((mdpt - round(Fs*((gap/2)-1)/1000)):(mdpt + round(Fs*((gap/2)-1)/1000))) = 0;

% PLAY STIM WITH BACKGROUND NOISE
figure(1); plot(0:(100+50)/1000*Fs,deviant(duration/2/1000*Fs-(gap+50)/2/1000*Fs:duration/2/1000*Fs+(gap+50)/2/1000*Fs));

%plotgapstim(stim);
plotstanddev();

function plotstanddev()
    
    standfft = fft(standard);
    standabs = abs(standfft);
    
    devfft = fft(deviant);
    devabs = abs(devfft);

    figure(2); plot(1:1000, devabs(1:1000), 'r', 1:1000, standabs(1:1000), 'b')
    % Notice that by adding a gap, ripples are created in the spectrum.
    % It appears the ripples are more pronounced when the gap is larger, but
    % I'm still unsure about this.

    % PLOT SPECTRUM OF DEVIANT AND STANDARD WITH NOISE
    %if (rp == 0)
    %    standfft = fft(stim(1:22050));
    %    devfft = fft(stim(44101:66150));
    %else
    %    standfft = fft(stim(44101:66150));
    %    devfft = fft(stim(1:22050));
    %end
    %standabs = abs(standfft);
    %devabs = abs(devfft);

    %figure(2); plot(1:1000, devabs(1:1000), 'r', 1:1000, standabs(1:1000), 'b')
    
end

end
