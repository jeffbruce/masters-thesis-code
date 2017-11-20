% summary: takes a .wav file containing several notes of an instrument,
% outputs a series of .wav files, one for each note.
% input: filename (e.g. 'piano 1.wav')
% output: a series of files ('piano 1 - 1.wav', ... , 'piano 1 - 10.wav')
function splitINSTRUMENT(filename)

[y,Fs,Ndepth] = wavread(filename);
sample_num = 1;

% choose length to average over, try 300
avg_array = zeros(length(y)-299,1);
instrument_true = zeros(length(y)-299,1);

% build array of average of 300 contiguous samples from the sound file
for i = 1:(length(avg_array))
    avg_array(i) = mean(abs(y(i:(i+299),1)));
end

% find all averages greater than a certain threshold; this indicates where
% sound is present
for i = 1:length(avg_array)
    avg = avg_array(i);
    if (avg > 0.002)  % 0.01 is an arbitrary threshold
        instrument_true(i) = 1;
    else
        instrument_true(i) = 0;
    end
end

for i = 2:length(instrument_true)
    
    if (instrument_true(i) ~= instrument_true(i-1))
        instrument_true(i-1) = -1;  % mark a crossing
    end  
    
end

crossings = find(instrument_true==-1);

if (mod(length(crossings),2) ~= 0)
    error('splitINSTRUMENT:odd number of crossings', msg);
else
    for i = 1:(length(crossings)/2)
        instrument = y(crossings(2*i-1):crossings(2*i),1);
        if (length(instrument) > 1000)
            wavwrite(instrument, Fs, Ndepth, strcat('C:\Users\Jeff\Documents\McMaster University\Neuro-Compensator Research\Music Perception\Timbre Perception\', filename, '-', num2str(sample_num)));
            sample_num = sample_num + 1;
        end
    end
end

end