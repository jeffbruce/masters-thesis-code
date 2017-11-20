% summary: takes as input a stereo .wav file, splits it up into two
% separate tracks and plots the power spectral density of both
function plotpsd(filename)

[y,Fs,Ndepth] = wavread(filename);

track1 = y(:,1);
track2 = y(:,2);
N = length(y);

t = 0:(1/Fs):(N/Fs);

nfft = 2^nextpow2(N);
t1Pxx = abs(fft(track1,nfft)).^2/N/Fs;
t2Pxx = abs(fft(track2,nfft)).^2/N/Fs;

% Create a single-sided spectrum
Hpsd1 = dspdata.psd(t1Pxx(1:length(t1Pxx)/2),'Fs',Fs);  
Hpsd2 = dspdata.psd(t2Pxx(1:length(t2Pxx)/2),'Fs',Fs);  

figure(1);plot(Hpsd1);
figure(2);plot(Hpsd2);

end