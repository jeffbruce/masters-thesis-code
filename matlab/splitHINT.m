% summary: takes a .wav file containing several sentences/noise and 
% outputs a series of .wav files, one for each sentence/noise.
% input: filename (e.g. '01 Track 1.wav')
% output: a series of files ('01 Track 1 - 1.wav', ... , '01 Track 1 -
% 10.wav')
function splitHINT(filename)

[y,Fs,Ndepth] = wavread(filename,'native');
sentence_num = 1;

avg_array = zeros(length(y)-9,1);
noise_true = zeros(length(y)-9,1);

% build array of average of 10 contiguous samples from the noise channel
% (first channel)
for i = 1:(length(avg_array))
    avg_array(i) = mean(abs(y(i:(i+9),1)));
end

% find all averages greater than a certain threshold; this indicates where
% noise is present
for i = 1:length(avg_array)
    avg = avg_array(i);
    if (avg > 3)  % 3 is an arbitrary threshold, but seems to work
        noise_true(i) = 1;
    else
        noise_true(i) = 0;
    end
end

for i = 2:length(noise_true)
    
    if (noise_true(i) ~= noise_true(i-1))
        noise_true(i-1) = -1;  % mark a crossing
    end  
    
end

crossings = find(noise_true==-1);

if (mod(length(crossings),2) ~= 0)
    error('splitHINT:odd number of crossings', msg);
else
    for i = 1:(length(crossings)/2)
        sentence = y(crossings(2*i-1):crossings(2*i),:);
        if (length(sentence) > 1000)
            wavwrite(sentence, Fs, Ndepth, strcat(filename, '-', num2str(sentence_num)));
            sentence_num = sentence_num + 1;
        end
    end
end

end
