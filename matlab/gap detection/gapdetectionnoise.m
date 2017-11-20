% adaptive (2 down, 1 up) 3AFC narrow band gap detection task
function gapdetectionnoise(hObject, handles, condition)

% SPECIFY PARAMETERS FOR EXPERIMENT
rand('seed', sum(100*clock()));
WindowAPI(run_gap_detection, 'Position', 'full');
%movegui(run_gap_detection,'northwest');

% sample rate
Fs = 44100;
Nf = Fs/2;
ISI = 500;

% stimulus parameters
freq = 1000;
duration = 500;
risefall = 50;
band = 50;

% gap parameters
gap = 100;
step = 40;  % in percent -> changes to 20 after 4 reversals
env = 1;
reversals = 12;
cur_reversal = 0;
streak = 0;
last = 0;
mid = 0;

pause(2);  % wait 3 seconds before first stimulus sequence
%HideCursor();

while (cur_reversal < reversals)

    % CREATE NARROW BAND STIMULUS

    % create 1000 Hz noise with 50 Hz bandwidth
    whitenz = wgn(1, duration/1000*Fs, 1);  %500ms duration
    B = fir1(1000,[(freq-band/2)/Nf, (freq+band/2)/Nf], hanning(1001));
    y = convn(whitenz,B,'same');  % create filtered signal

    % apply 50ms rise and fall
    y(1:(risefall/1000*Fs)) = sin([0:((risefall/1000*Fs)-1)]*pi/4410).*y(1:(risefall/1000*Fs));  
    y(((duration/1000*Fs)-risefall/1000*Fs+1):(duration/1000*Fs)) = cos([0:((risefall/1000*Fs)-1)]*pi/4410).*y(((duration/1000*Fs)-risefall/1000*Fs+1):(duration/1000*Fs));  % apply 50ms fall


    % CREATE NOTCHED BACKGROUND NOISE

    backgrnd = wgn(1, (duration+ISI+duration+ISI+duration)/1000*Fs, 1);
    B = fir1(1000,[(freq-band/2)/Nf, (freq+band/2)/Nf], 'stop');
    backgrnd = convn(backgrnd,B,'same');  % create filtered signal

    % scale background noise to make it quieter
    backgrnd = backgrnd.*0.04;

    % apply 50ms rise and fall
    backgrnd(1:(risefall/1000*Fs)) = sin([0:((risefall/1000*Fs)-1)]*pi/4410).*backgrnd(1:(risefall/1000*Fs));  
    backgrnd((((duration+ISI+duration+ISI+duration)/1000*Fs)-risefall/1000*Fs+1):((duration+ISI+duration+ISI+duration)/1000*Fs)) = cos([0:((risefall/1000*Fs)-1)]*pi/4410).*backgrnd((((duration+ISI+duration+ISI+duration)/1000*Fs)-risefall/1000*Fs+1):((duration+ISI+duration+ISI+duration)/1000*Fs));


    % CREATE THE STANDARD AND DEVIANT

    % create standard
    t = 0:(1/Fs):(duration/1000)-(1/Fs);
    standard = y;

    % create deviant by cos^2 windowing the standard, then adding a gap
    deviant = standard;
    mdpt = round(length(standard)/2);

    s = warning('off','all');

    % apply cos^2 window with env (ms) duration
    coef = cos([0:(1/Fs):(env/1000)-(1/Fs)]*(1000/env)*(pi/2)).^2;
    deviant((mdpt - Fs*(gap/2/1000)):(mdpt - Fs*((gap/2)-1)/1000 - 1)) = ...
        coef.*deviant((mdpt - Fs*(gap/2/1000)):(mdpt - Fs*((gap/2)-1)/1000 - 1));

    coef = sin([0:(1/Fs):(env/1000)-(1/Fs)]*(1000/env)*(pi/2)).^2;
    deviant((mdpt + Fs*((gap/2)-1)/1000 + 1):(mdpt + Fs*(gap/2/1000))) = ...
        coef.*deviant((mdpt + Fs*((gap/2)-1)/1000 + 1):(mdpt + Fs*(gap/2/1000)));

    warning(s);

    % add a gap between the two windows
    deviant((mdpt - round(Fs*((gap/2)-1)/1000)):(mdpt + round(Fs*((gap/2)-1)/1000))) = 0;

    %varstand = var(standard)
    %vardev = var(deviant)

    % PLAY STIM WITH BACKGROUND NOISE

    stim = zeros(1,(duration+ISI+duration+ISI+duration)/1000*Fs);
    rp = round(2*rand(1));

    if (rp == 0)  % the deviant is first
        stim(1:(duration/1000*Fs)) = deviant;
        stim((duration+ISI)/1000*Fs+1:(duration+ISI+duration)/1000*Fs) = standard;
        stim((duration+ISI+duration+ISI)/1000*Fs+1:(duration+ISI+duration+ISI+duration)/1000*Fs) = standard;
    elseif (rp == 1)  % the deviant is second
        stim(1:(duration/1000*Fs)) = standard;
        stim((duration+ISI)/1000*Fs+1:(duration+ISI+duration)/1000*Fs) = deviant;
        stim((duration+ISI+duration+ISI)/1000*Fs+1:(duration+ISI+duration+ISI+duration)/1000*Fs) = standard;
    elseif (rp == 2)  % the deviant is third
        stim(1:(duration/1000*Fs)) = standard;
        stim((duration+ISI)/1000*Fs+1:(duration+ISI+duration)/1000*Fs) = standard;
        stim((duration+ISI+duration+ISI)/1000*Fs+1:(duration+ISI+duration+ISI+duration)/1000*Fs) = deviant;
    end

    stim = stim+backgrnd;
    %plotgapstim(stim);
    %stim
    %plotstanddev();
    %stim = backgrnd;
    stim(2,1:end) = 0;
    stim(1,end:end+2205) = 0;  % eliminate click by extending stimulus 50ms longer
    stim(2,end:end+2205) = 0;

    Snd('Play',stim,Fs);
    Snd('Wait');
    set(handles.pushbutton1,'Enable','on');
    set(handles.pushbutton2,'Enable','on');
    set(handles.pushbutton4,'Enable','on');
    
    check_response(rp);

    pause(1);

    % PLOT SPECTRUM OF STANDARD AND DEVIANT
    %plotstanddev(); % causes error if used with rest of function after 1st
    %presentation

    if (cur_reversal == 6 && mid == 0) % have reached the halfway point

        set(handles.pushbutton3,'String','Continue');
        set(handles.text2,'String','You are halfway through the experiment.  Take a short break if you like.');
        set(handles.pushbutton3,'Visible','on');
        set(handles.text2,'Visible','on');
        set(handles.pushbutton1,'Visible','off');
        set(handles.pushbutton2,'Visible','off');
        set(handles.pushbutton4,'Visible','off');

        guidata(gcf,handles);

        while handles.midway < 1
            pause(0.01);
            handles = guidata(gcf);
        end

        mid = 1;

        pause(3);

    end

end

display_ending(handles);


function display_ending(handles)
    set(handles.pushbutton1,'Enable','off');
    set(handles.pushbutton1,'Visible','off');
    set(handles.pushbutton2,'Enable','off');
    set(handles.pushbutton2,'Visible','off');
    set(handles.pushbutton4,'Enable','off');
    set(handles.pushbutton4,'Visible','off');
    set(handles.text2,'String','You have completed the experiment!');
    set(handles.text2,'Visible','on');
    guidata(gcf,handles);
    ShowCursor();
end


% compare subject response to correct response
function check_response(rp)
    
    while (handles.clicked == 0)  % spin until a button is clicked
        pause(0.01);
        handles = guidata(gcf);
    end
    
    resp = handles.resp;
    handles.clicked = 0;
    
    if (rp + 1 == resp)
        str = 'correct';
        set(handles.text3,'Visible','on');
        guidata(gcf, handles);
    else
        str = 'incorrect';
        set(handles.text5,'Visible','on');
        guidata(gcf, handles);
    end

    set(handles.pushbutton1,'Enable','off');
    set(handles.pushbutton2,'Enable','off');
    set(handles.pushbutton4,'Enable','off');
    pause(2);  % allow 2 secs for feedback
    set(handles.text3,'Visible','off');
    set(handles.text5,'Visible','off');
    guidata(gcf,handles);
    
    fprintf(handles.fileID, strcat(num2str(gap), ['\t', num2str(rp+1)], ['\t', num2str(resp)], ['\t', num2str(last)], ['\t', num2str(streak)], ['\t', num2str(cur_reversal)], '\n'));
    
    if ((rp + 1) == resp)
        streak = streak + 1;
        if (streak == 2)
            streak = 0;
            if (last == -1)
                cur_reversal = cur_reversal + 1;
            end
            last = 1;
            gapify(last);
        end
    else
        streak = 0;
        if (last == 1)
            cur_reversal = cur_reversal + 1;
        end
        last = -1;
        gapify(last);
    end
    
end


% adaptively adjust the gap duration
function gapify(last)
    
    if (cur_reversal == 4)
        step = 20;
    end
    
    if (last == -1)  % increase size of the gap
        gap = round(gap*(100+step)/100);
    else  % last == 1, decrease size of the gap
        gap = round(gap/(100+step)*100);
    end
        
end


% plots spectrum of standard and deviant
function plotstanddev()
    
    standfft = fft(standard);
    standabs = abs(standfft);
    
    devfft = fft(deviant);
    devabs = abs(devfft);

    figure(1); plot(1:1000, devabs(1:1000), 'r', 1:1000, standabs(1:1000), 'b')
    % Notice that by adding a gap, ripples are created in the spectrum.
    % It appears the ripples are more pronounced when the gap is larger, but
    % I'm still unsure about this.

    % PLOT SPECTRUM OF DEVIANT AND STANDARD WITH NOISE
    if (rp == 0)
        standfft = fft(stim(1:22050));
        devfft = fft(stim(44101:66150));
    else
        standfft = fft(stim(44101:66150));
        devfft = fft(stim(1:22050));
    end
    standabs = abs(standfft);
    devabs = abs(devfft);

    figure(2); plot(1:1000, devabs(1:1000), 'r', 1:1000, standabs(1:1000), 'b')
    
end

function plotgapstim(s)
    figure(3); plot(0:1/44100:2.5-1/44100,s);
    ylabel('Intensity');
    xlabel('Time (sec)');
    title('Gap Stimulus Waveform');
end

end