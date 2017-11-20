% summary: runs the mistuned harmonic experiment
% method: 2AFC, 500ms ISI, 1s between trials, mistuned 2nd, 5th, 8th
%         interleaved staircases (2 down 1 up), 12 reversals, 
%         adaptively mistune harmonic, fixed step size of 1.4
% stimulus: 200Hz, 500ms, 10 harmonics (includes fundamental), equal power
%         for each harmonic, randomized phase
function mistuned_harmonic(hObject, handles, condition)

% randomize randomization and open subject data file
rand('seed', sum(100*clock()));
movegui(run_mistuned_harmonic,'northwest');

% STIMULUS PARAMETER SPECIFICATION AND STIMULUS CREATION
Fs = 44100;
j = sqrt(-1);
up = 0;
factor = 0.4;
curfactor = [1.3 1.3 1.3];  % start mistuning at obvious level
altered = 0;
reversal = [0 0 0];
last = [1 1 1];
streak = [0 0 0];
staircase = 1;

% stimulus
comptone = zeros(2.5*Fs, 1);

pause(3);  % 3 seconds until the first stimulus
%HideCursor();

while (reversal(condition) < 12)
   
    %for i = 1:3
        
        if (reversal(condition) < 12)
        
            staircase = condition;
            altered = ceil(rand(1)*3);
            
            comptone = create_stimulus();
            comptone = comptone';

            Snd('Play',comptone, Fs);
            Snd('Wait');
            wait_for_response();  % allow response and 2 secs for feedback
            pause(1);
            
        end

    %end
    
    % warn participant that the experiment is half done and that they
    % may take a break if needed.
    if (reversal(condition) > 5 && handles.midway < 1 )  
        
        set(handles.pushbutton3,'String','Continue');
        set(handles.text2,'String','You are halfway through the experiment.  Take a short break if you like.');
        set(handles.pushbutton3,'Visible','on');
        set(handles.text2,'Visible','on');
        set(handles.pushbutton1,'Enable','off');
        set(handles.pushbutton1,'Visible','off');
        set(handles.pushbutton2,'Enable','off');
        set(handles.pushbutton2,'Visible','off');
        set(handles.pushbutton4,'Enable','off');
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
    set(handles.pushbutton4,'Enable','off');
    set(handles.pushbutton4,'Visible','off');
    set(handles.text2,'String','You have completed the experiment!');
    set(handles.text2,'Visible','on');
    guidata(gcf,handles);
    ShowCursor();
end


% sc == 1      => mistune 400Hz
% sc == 2      => mistune 1000Hz
% sc == 3      => mistune 1600Hz
% altered == 1 => mistune first stimulus in pairing
% altered == 2 => mistune second stimulus in pairing
% altered == 3 => mistune third stimulus in pairing
function [c] = create_stimulus()
        
    % create 10 random phases (-pi, pi); technically it should be (-pi, pi]
    % based on random phases and specified modulus, calculate real and imag
    % parts
    phase = [2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi]; 
    modulus = [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000];
    real = sqrt(modulus.^2./([1,1,1,1,1,1,1,1,1,1]+tan(phase).^2));
    imag = sqrt(modulus.^2 - real.^2);
    
    c = zeros(Fs*2.5, 1);  % 2.5 seconds long
    sigfft = zeros(44100,1);
    
    % CREATE ORIG SIGNAL
    
    for i=1:10
        sigfft(1+i*200) = real(i) + j*imag(i);
        sigfft(44100+1-i*200) = real(i) - j*imag(i);
        %sigfft(1+i*200) = 1000;
        %sigfft(44100+1-i*200) = 1000;
    end
    
    sig = ifft(sigfft);
    sig = sig(1:22050);  % take half of the signal
    
    % apply linear 10ms rise/fall to the signal
    for i=1:Fs*0.01
        sig(i) = sig(i)*(i/(Fs*0.01));
        sig(22051-i) = sig(22051-i)*(i/(Fs*0.01));
    end
    
    % CREATE MISTUNED SIGNAL
    
    up = floor(rand(1)*2);  % up == 0 => mistune down
                            % up == 1 => mistune up
    
    if staircase == 1  % mistune 400Hz
        if up == 0
            sigfft(400+1) = 0;
            sigfft(44100-400+1) = 0;
            sigfft(round(400*(1/curfactor(staircase)))+1) = real(2) + j*imag(2);
            sigfft(44100-round(400*(1/curfactor(staircase)))+1) = real(2) - j*imag(2);
        else  % up == 1
            sigfft(400+1) = 0;
            sigfft(44100-400+1) = 0;
            sigfft(round(400*curfactor(staircase))+1) = real(2) + j*imag(2);
            sigfft(44100-round(400*curfactor(staircase))+1) = real(2) - j*imag(2);
        end
    elseif staircase == 2  % mistune 1000Hz
        if up == 0
            sigfft(1000+1) = 0;
            sigfft(44100-1000+1) = 0;
            sigfft(round(1000*(1/curfactor(staircase)))+1) = real(5) + j*imag(5);
            sigfft(44100-round(1000*(1/curfactor(staircase)))+1) = real(5) - j*imag(5);
        else  % up == 1
            sigfft(1000+1) = 0;
            sigfft(44100-1000+1) = 0;
            sigfft(round(1000*curfactor(staircase))+1) = real(5) + j*imag(5);
            sigfft(44100-round(1000*curfactor(staircase))+1) = real(5) - j*imag(5);
        end
    else  % staircase == 3  % mistune 1600Hz
        if up == 0
            sigfft(1600+1) = 0;
            sigfft(44100-1600+1) = 0;
            sigfft(round(1600*(1/curfactor(staircase)))+1) = real(8) + j*imag(8);
            sigfft(44100-round(1600*(1/curfactor(staircase)))+1) = real(8) - j*imag(8);
        else  % up == 1
            sigfft(1600+1) = 0;
            sigfft(44100-1600+1) = 0;
            sigfft(round(1600*curfactor(staircase))+1) = real(8) + j*imag(8);
            sigfft(44100-round(1600*curfactor(staircase))+1) = real(8) - j*imag(8);
        end
    end
    
    newsig = ifft(sigfft);
    
    % apply linear 10ms rise/fall to the MISTUNED signal
    newsig = newsig(1:22050);
    for i=1:Fs*0.01
        newsig(i) = newsig(i)*(i/(Fs*0.01));
        newsig(22051-i) = newsig(22051-i)*(i/(Fs*0.01));
    end
    
    % ASSIGN APPROPRIATE ORDER
    
    if altered == 1
        c(1:0.5*Fs) = newsig;
        c(Fs+1:1.5*Fs) = sig;
        c(2*Fs+1:2.5*Fs) = sig;
    elseif altered == 2
        c(1:0.5*Fs) = sig;
        c(Fs+1:1.5*Fs) = newsig;
        c(2*Fs+1:2.5*Fs) = sig;
    elseif altered == 3
        c(1:0.5*Fs) = sig;
        c(Fs+1:1.5*Fs) = sig;
        c(2*Fs+1:2.5*Fs) = newsig;
    end
    %plot_tuned_spectrum(c,altered);
    
    c(1:end,2) = 0;  % make stereo signal
    c(end+1:end+2205,1) = 0;  % eliminate click by making stimulus 50ms longer
    c(end+1:end+2205,2) = 0;
    
end


function wait_for_response()
        
    set(handles.pushbutton1,'Enable','on');
    set(handles.pushbutton2,'Enable','on');
    set(handles.pushbutton4,'Enable','on');
    
    while (handles.clicked == 0)  % spin until a button is clicked
        pause(0.01);
        handles = guidata(gcf);
    end
    
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

    set(handles.pushbutton1,'Enable','off');
    set(handles.pushbutton2,'Enable','off');
    set(handles.pushbutton4,'Enable','off');
    pause(2);  % allow 2 secs for feedback
    set(handles.text3,'Visible','off');
    set(handles.text5,'Visible','off');
    guidata(gcf,handles);
    
    fprintf(handles.fileID, strcat(num2str(staircase), ['\t' num2str(reversal(staircase))], ['\t\t' num2str(streak(staircase))], ['\t' num2str(last(staircase))], ['\t\t' num2str(curfactor(staircase))], ['\t' num2str(up)], ['\t' num2str(altered)], ['\t', num2str(resp)], ['\t', str],'\n'));
    
    if (strcmp(str,'correct'))  
        if (streak(staircase) == 1)  % answered 2 correct
            streak(staircase) = 0;
            curfactor(staircase) = compute_factor(staircase, str);
            if (last(staircase) == -1)
                reversal(staircase) = reversal(staircase) + 1;
                last(staircase) = 1;
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
    end
    
end


function [f] = compute_factor(sc, str)
        
    if strcmp(str, 'correct')  % decrease mistuning -- make task harder

        if abs(curfactor(sc) - 1.0010) < 0.0005
            f = 1.0010;
        else
            f = round2(curfactor(sc)-(curfactor(sc)-1)*factor, 0.001);
        end
            
    else  % increase mistuning -- make task easier
        
        if abs(curfactor(sc) - 1.0010) < 0.0005
            f = 1.0020;
        else
            f = round2(curfactor(sc)+(curfactor(sc)-1)*factor, 0.001);
        end
        
    end
           
end


function plot_mistuned_spectrum(c, altered)
    if (altered == 1)
        
        altharmfft = fft(c(1:0.5*Fs));
        altharmabs = abs(altharmfft);
        figure(1); plot(0:2:6000,altharmabs(1:3001));
        
    elseif (altered == 2)
        
        altharmfft = fft(c(Fs+1:1.5*Fs));
        altharmabs = abs(altharmfft);
        figure(1); plot(0:2:6000,altharmabs(1:3001));
        
    else  % altered == 3
        
        altharmfft = fft(c(2*Fs+1:2.5*Fs));
        altharmabs = abs(altharmfft);
        figure(1); plot(0:2:6000,altharmabs(1:3001));  
        
    end
    
    title('Mistuned Harmonic (200Hz) Spectrum - 8th harmonic mistuned');
    ylabel('Intensity');
    xlabel('Frequency (Hz)');
    axis([0 2500 0 800]);
end


function plot_tuned_spectrum(c, altered)
    if (altered == 2 || altered == 3)
        
        harmfft = fft(c(1:0.5*Fs));
        harmabs = abs(harmfft);
        figure(1); plot(0:2:6000,harmabs(1:3001));
        
    else  % altered == 1
        
        harmfft = fft(c(Fs+1:1.5*Fs));
        harmabs = abs(harmfft);
        figure(1); plot(0:2:6000,harmabs(1:3001));
        
    end
    
    title('Mistuned Harmonic (200Hz) Spectrum - No Mistuning');
    ylabel('Intensity');
    xlabel('Frequency (Hz)');
    axis([0 2500 0 800]);
end


end