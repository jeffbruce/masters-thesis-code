% summary: runs the timbre perception experiment
% 3AFC (2 unaltered, 1 altered)
% 3 instruments, 3 altered partials, will want 2 notes
%       saxophone (F5), violin (D5, C6 vibrato), acoustic guitar (D#4)
%       altered partials by reducing it by some percentage 
function adaptive_timbre_practice(hObject, handles, condition)

% randomize presentation order AND open subject data file
rand('seed', sum(100*clock()));
movegui(run_timbre_exp_practice,'north');

% STIMULUS PARAMETER SPECIFICATION AND STIMULUS CREATION
Fs = 44100;
factor = [0.4 0.1 0.3; 0.2 0.05 0.15];  % adaptive step size in dB (40%, 20%)
curfactor = [0 0 0];
curpowDB = [22.9741 24.8274 23.7745];  % calculated pwr for remfund, 1strem, 2ndrem
maxpowDB = [25.2905 25.2905 25.2905];
minpowDB = [22.9741 24.8274 23.7745];
altered = 0;
reversal = [0 0 0];
last = [1 1 1];
streak = [0 0 0];
staircase = 1;
step = [1 1 1];
count = 1;
sax1 = wavread('C:\Users\user\Documents\MATLAB\Neuro-Compensator\timbre perception\271\271TSNOM-22-F5');  % 1 second
%vio1 = wavread('151\151VNNOM-33-C6vibrato');  % 4 seconds
%vio2 = wavread('151\151VNNOM-14-D5');  % 3 seconds
%trum1 = wavread('212\212TRNOM-16');  % 2 seconds
%gui1 = wavread('111\111AGAFM-54-D#4');  % 5 seconds
sax1(end+1:Fs) = 0;
%vio1(end+1:Fs*4) = 0;
%vio2(end+1:Fs*3) = 0;
%trum1(end+1:Fs*2) = 0;
%gui1(end+1:Fs*5) = 0;

sax1fft = fft(sax1);
sax1abs = abs(sax1fft);
sax1pwr = sum((sax1abs(:).^2)/length(sax1));

pause(3);
HideCursor();

while (count <= 6 ) % || reversal(2) < 12 || reversal(3) < 12)
   
    count = count + 1;
    %for i = 1:3
        
        if (reversal(condition) < 12)
        
            staircase = condition;
            alteredsax1 = alter_sax(condition);
            altered = ceil(rand(1)*2)+1;

            if (altered == 2)  % altered stim appears in 3rd sec
                sax_stim(1,1:44100) = sax1;
                sax_stim(1,88201:132300) = alteredsax1;
                sax_stim(1,176401:220500) = sax1;
            else               % altered stim appears in 5th sec
                sax_stim(1,1:44100) = sax1;
                sax_stim(1,88201:132300) = sax1;
                sax_stim(1,176401:220500) = alteredsax1;
            end
            
            sax_stim(2,:) = 0;
            sax_stim(1,end:end+2205) = 0;  % eliminate click by extending stim 50ms
            sax_stim(2,end:end+2205) = 0;
            Snd('Play', sax_stim, Fs);   
            Snd('Wait');
            
            wait_for_response();
            pause(1);
            
        end

    %end
    
    % warn participant that the experiment is half done and that they
    % may take a break if needed.
    if (reversal(condition) > 5 && handles.midway < 1 )  % && reversal(2) > 5 && reversal(3) > 5)    
        
        set(handles.pushbutton3,'String','Continue');
        set(handles.pushbutton3,'Visible','on');
        set(handles.text2,'String','You are halfway through the experiment.  Take a short break if you like.');
        set(handles.text2,'Visible','on');
        
        set(handles.pushbutton1,'Visible','off');
        set(handles.pushbutton2,'Visible','off');
        set(handles.pushbutton4,'Visible','off');
        
        guidata(gcf,handles);
        
        while handles.midway < 1
            pause(0.01);
            handles = guidata(gcf);
        end
        
        pause(3);
        
    end
    
end

display_ending(handles);


function display_ending(handles)
    set(handles.pushbutton1,'Enable','off');
    set(handles.pushbutton1,'Visible','off');
    set(handles.pushbutton2,'Enable','off');
    set(handles.pushbutton2,'Visible','off');
    set(handles.pushbutton4,'Visible','off');
    set(handles.text2,'String','You have completed the practice session.');
    set(handles.text2,'Visible','on');
    guidata(gcf,handles);
    ShowCursor();
end


% saxophone is F5, 351 Hz
% therefore harm1 = 351 Hz, harm2 = 702 Hz, harm3 = 1053 Hz
function [alteredsax1] = alter_sax(harm)
    
    sax_stim = zeros(1,220500);  % 5 seconds (1 sec stim, 1 sec ISI)
    sax1fft = fft(sax1);
    
    if (harm == 1)
        sax1fft((351-100)+1 : (351+100)+1) = sax1fft((351-100)+1 : (351+100)+1) * curfactor(staircase);  % 251 to 451
        sax1fft(44100-(351+100)+1 : 44100-(351-100)+1) = sax1fft(44100-(351+100)+1 : 44100-(351-100)+1) * curfactor(staircase);  % 43650 to 43850
    elseif (harm == 2)
        sax1fft((702-100)+1 : (702+100)+1) = sax1fft((702-100)+1 : (702+100)+1) * curfactor(staircase);  % 602 to 802
        sax1fft(44100-(702+100)+1 : 44100-(702-100)+1) = sax1fft(44100-(702+100)+1 : 44100-(702-100)+1) * curfactor(staircase);  % 43299 to 43499
    else  % (harm == 3)
        sax1fft((1053-100)+1 : (1053+100)+1) = sax1fft((1053-100)+1 : (1053+100)+1) * curfactor(staircase);  % 953 to 1153
        sax1fft(44100-(1053+100)+1 : 44100-(1053-100)+1) = sax1fft(44100-(1053+100)+1 : 44100-(1053-100)+1) * curfactor(staircase);  % 43299 to 43499
    end
    
    % equalize power for stim 1, 2, 3
    alteredabs = abs(sax1fft);
    alteredpwr = (1/length(sax1))*sum(alteredabs.^2);
    mult = sqrt(sax1pwr/alteredpwr);
    sax1fft = sax1fft*mult;
    alteredsax1 = ifft(sax1fft);
    
    % confirm they are same power
    % alteredabs = abs(sax1fft);
    % sax1pwr
    % alteredpwr = (1/length(sax1))*sum(alteredabs.^2)
    
end


function wait_for_response()
    
    set(handles.pushbutton1,'Enable','on');
    set(handles.pushbutton2,'Enable','on');
    
    while (handles.clicked == 0)  % spin until a button is clicked
        pause(0.01);
        handles = guidata(gcf);
    end
    
    set(handles.pushbutton1,'Enable','off');
    set(handles.pushbutton2,'Enable','off');
    
    resp = handles.resp;
    handles.clicked = 0;
    
    if (resp == altered)
        str = 'correct';
        set(handles.text3,'Visible','on');
        guidata(gcf, handles);
    else
        str = 'incorrect';
        set(handles.text5,'Visible','on');
        guidata(gcf, handles);
    end

    pause(2);  % allow 2 secs for feedback
    set(handles.text3,'Visible','off');
    set(handles.text5,'Visible','off');
    guidata(gcf,handles);
    
    fprintf(handles.fileID, strcat(num2str(staircase), ['\t' num2str(reversal(staircase))], ['\t\t' num2str(streak(staircase))], ['\t' num2str(last(staircase))], ['\t' num2str(curpowDB(staircase))], ['\t\t' num2str(factor(step(staircase), staircase))], ['\t' num2str(altered)], ['\t', num2str(resp)], ['\t', str],'\n'));
    
    if (strcmp(str,'correct'))  
        if (streak(staircase) == 1)  % answered 2 correct
            streak(staircase) = 0;
            curfactor(staircase) = compute_factor(staircase, str);
            if (last(staircase) == -1)
                reversal(staircase) = reversal(staircase) + 1;
                last(staircase) = 1;
            end
            % if curpowDB is greater than max, set as max
            curpowDB(staircase) = curpowDB(staircase) + factor(step(staircase), staircase);
            if (curpowDB(staircase) > maxpowDB(staircase))
                curpowDB(staircase) = maxpowDB(staircase);
            end
        else
            streak(staircase) = streak(staircase) + 1;
        end
    else  % incorrect
        streak(staircase) = 0;
        curfactor(staircase) = compute_factor(staircase, str);
        if (last(staircase) == 1)
            reversal(staircase) = reversal(staircase) + 1;
            last(staircase) = -1;
        end
        % if curpowDB is less than min, set as min
        curpowDB(staircase) = curpowDB(staircase) - factor(step(staircase), staircase);
        if (curpowDB(staircase) < minpowDB(staircase))
            curpowDB(staircase) = minpowDB(staircase);
        end
    
    end
    
    % factor e R (0,1) 
    if (curfactor(staircase) > 1)
        curfactor(staircase) = 1;
    elseif (curfactor(staircase) < 0)
        curfactor(staircase) = 0;        
    end
    
    % adjust the step size after 4 reversals
    if (reversal(staircase) == 4)
        step(staircase) = 2;
    end
    
end


function [scalar] = compute_factor(sc, str)
        
    if strcmp(str, 'correct')  % increase power -- make task harder

        if (sc == 1)
            scalar = sqrt(1 - (sum(sax1abs.^2/length(sax1)) - db2pow(curpowDB(sc)+factor(step(sc),sc))) / (2*sum(sax1abs(351-100:351+100).^2)/length(sax1)) );
        elseif (sc == 2)
            scalar = sqrt(1 - (sum(sax1abs.^2/length(sax1)) - db2pow(curpowDB(sc)+factor(step(sc),sc))) / (2*sum(sax1abs(702-100:702+100).^2)/length(sax1)) );
        else  % sc == 3
            scalar = sqrt(1 - (sum(sax1abs.^2/length(sax1)) - db2pow(curpowDB(sc)+factor(step(sc),sc))) / (2*sum(sax1abs(1053-100:1053+100).^2)/length(sax1)) );
        end
    
    else  % decrease power -- make task easier
        
        if curfactor(sc) <= 0
            scalar = 0;
        else
            if (sc == 1)
                scalar = sqrt(1 - (sum(sax1abs.^2/length(sax1)) - db2pow(curpowDB(sc)-factor(step(sc),sc))) / (2*sum(sax1abs(351-100:351+100).^2)/length(sax1)) );
            elseif (sc == 2)
                scalar = sqrt(1 - (sum(sax1abs.^2/length(sax1)) - db2pow(curpowDB(sc)-factor(step(sc),sc))) / (2*sum(sax1abs(702-100:702+100).^2)/length(sax1)) );
            else  % sc == 3
                scalar = sqrt(1 - (sum(sax1abs.^2/length(sax1)) - db2pow(curpowDB(sc)-factor(step(sc),sc))) / (2*sum(sax1abs(1053-100:1053+100).^2)/length(sax1)) ); 
            end
        end
        
        % if curfactor is close to zero or has imaginary parts, set to zero
        if imag(scalar) ~= 0
            scalar = 0;
        elseif abs(scalar) < 0.01
            scalar = 0;
        end
            
    end
           
end


end