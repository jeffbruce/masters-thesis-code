% summary: takes as input a stereo .wav file, splits it up into two
% separate tracks and plots the mean square power spectrum of both
function plotmsps(filename)

[y,Fs,Ndepth] = wavread(filename);

track1 = y(:,1);
track2 = y(:,2);
N = length(y);

t = 0:(1/Fs):(N/Fs);

T1 = fft(track1);
T1 = T1(1:(length(T1)/2 - 1));
P1 = (abs(T1)/length(y)).^2;
P1(2:end-1) = 2*P1(2:end-1);

T2 = fft(track2);
T2 = T2(1:(length(T2)/2 - 1));
P2 = (abs(T2)/length(y)).^2;
P2(2:end-1) = 2*P2(2:end-1);

% Create a single-sided spectrum
Hmsps1 = dspdata.msspectrum(P1,'Fs',Fs,'spectrumtype','onesided');  
Hmsps2 = dspdata.msspectrum(P2,'Fs',Fs,'spectrumtype','onesided');

figure(1);plot(Hmsps1);
figure(2);plot(Hmsps2);

end