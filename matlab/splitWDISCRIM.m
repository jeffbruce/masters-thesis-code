% PRESSED FOR TIME, DOES NOT CURRENTLY WORK.  MANUALLY CREATED THE FILES
% summary: purpose was to split the NU6 word tracks into a separate file
% for each word
% input: filename (e.g. '01 Track 1.wav')
% output: a series of files ('01 Track 1 - 1.wav', ... , '01 Track 1 -
% 10.wav')
function splitWDISCRIM(filename)

[y,Fs,Ndepth] = wavread(filename,'native');
sentence_num = 1;

avg_array = zeros(length(y)-9,1);
sound_true = zeros(length(y)-9,1);

% build array of average of 10 contiguous samples from the sound sample
for i = 1:(length(avg_array))
    avg_array(i) = mean(abs(y(i:(i+9))));
end

% find all averages greater than a certain threshold; this indicates where
% sound is present
for i = 1:length(avg_array)
    avg = avg_array(i);
    if (avg > 3)  % 3 is an arbitrary threshold, but seems to work
        sound_true(i) = 1;
    else
        sound_true(i) = 0;
    end
end

for i = 2:length(sound_true)
    
    if (sound_true(i) ~= sound_true(i-1))
        sound_true(i-1) = -1;  % mark a crossing
    end  
    
end

crossings = find(sound_true==-1);

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
