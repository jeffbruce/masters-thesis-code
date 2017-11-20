[nz,fs] = wavread('C:\Users\Jeff\Documents\MATLAB\Neuro-Compensator\hVd\noise\babble16000.wav');

randomnum = floor(233*rand(1));
nzsegment = nz(randomnum+1:randomnum+32000);

% spectrogram attributes
window = 256;
noverlap = 128;
nfft = 256;
fs = 16000;

[S,F,T,P] = spectrogram(nzsegment,window,noverlap,nfft,fs);
surf(T,F,10*log10(P),'edgecolor','none'); 
axis tight; 
view(0,90);
xlabel('Time (Seconds)','FontSize',12); 
ylabel('Hz','FontSize',12);

% power spectral density
%plot(psd(spectrum.periodogram,nzsegment,'Fs',fs,'NFFT',length(nzsegment)));