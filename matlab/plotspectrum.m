% summary: takes as input a stereo .wav file, splits it up into two
% separate tracks and plots the spectrum of both

function plotspectrum(filename)

[y,Fs,Ndepth] = wavread(filename);

track1 = y(:,1);
track2 = y(:,2);

N = length(track1);

mult = fsmultiple(N,Fs);
track1(end:mult*Fs) = 0;
track2(end:mult*Fs) = 0;

length(track1)
length(track2)

t1fft = fft(track1);
t1fftabs = abs(t1fft);

t2fft = fft(track2);
t2fftabs = abs(t2fft);

figure(1); plot(0:(Fs/N):(20000*Fs/N),t1fftabs(1:20001)*(2/N),'.g',0:(Fs/N):(20000*Fs/N),t2fftabs(1:20001)*(2/N),'.r');

end

function mult = fsmultiple(N,Fs)

mult = 1;

for i=1:15;
    if (mult*Fs > N)
        return;
    else
    mult = mult + 1;
    end
end

end