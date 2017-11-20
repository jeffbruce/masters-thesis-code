% summary: constructs an array of (bandwidth, speaker) pairings.
function [randstimuli] = init_localization(lowhigh)

% pre-allocate space for 1/3 octave noise bands
stimuli = zeros(28,2);
randstimuli = zeros(28,2);

if lowhigh == 1  % phone sample
    for i = 1:7
        stimuli((4*(i-1)+1):4*i,1) = -1;
        stimuli((4*(i-1)+1):4*i,2) = i;
    end
elseif lowhigh == 2  % low freq 
    for i = 1:7  % number of speakers
        stimuli((4*(i-1)+1):4*i,1) = 500;
        stimuli((4*(i-1)+1):4*i,2) = i;
    end
elseif lowhigh == 3  % high freq
    for i = 1:7  % number of speakers
        stimuli((4*(i-1)+1):4*i,1) = 3000;
        stimuli((4*(i-1)+1):4*i,2) = i;
    end
end

% shuffle presentation order
rp = randperm(length(stimuli));
randstimuli = stimuli(rp,:);

end