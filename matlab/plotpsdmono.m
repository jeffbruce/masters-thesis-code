% summary: takes as input a mono .wav file, plots spectral density
function plotpsdmono(filename)

[y,Fs,Ndepth] = wavread(filename);

track1 = y(:,1);
N = length(y);

t = 0:(1/Fs):(N/Fs);

nfft = 2^nextpow2(N);
t1Pxx = abs(fft(track1,nfft)).^2/N/Fs;

% Create a single-sided spectrum
Hpsd1 = dspdata.psd(t1Pxx(1:length(t1Pxx)/2),'Fs',Fs);   

figure(1);plot(Hpsd1);

end