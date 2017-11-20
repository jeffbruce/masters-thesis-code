function varargout = vcv(varargin)
% VCV M-file for vcv.fig
%      VCV, by itself, creates a new VCV or raises the existing
%      singleton*.
%
%      H = VCV returns the handle to a new VCV or the handle to
%      the existing singleton*.
%
%      VCV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VCV.M with the given input arguments.
%
%      VCV('Property','Value',...) creates a new VCV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before vcv_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to vcv_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help vcv

% Last Modified by GUIDE v2.5 22-Oct-2011 12:51:42

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vcv_OpeningFcn, ...
                   'gui_OutputFcn',  @vcv_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before vcv is made visible.
function vcv_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to vcv (see VARARGIN)

global clicked;

% Choose default command line output for vcv
handles.output = hObject;

[RP2,RV8,PA5x1,PA5x2] = load_circuits_vcv();

handles.RP2 = RP2;
handles.RV8 = RV8;
handles.PA5x1 = PA5x1;
handles.PA5x2 = PA5x2;

[newfilecell,bab,Fs,depth] = init_vcv();

handles.subjname = input('Input subject name: ','s');
handles.fileID = fopen(strcat('C:\Users\user\Documents\MATLAB\Neuro-Compensator\vcv\data\',handles.subjname,'.txt'), 'w');

handles.newfilecell = newfilecell;
handles.bab = bab;
handles.Fs = Fs;
handles.depth = depth;
handles.count = 1;

clicked = 0;

hide_activeX_controls(handles);
disable_buttons(handles);

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes vcv wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = vcv_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

    global clicked;

    Fs = handles.Fs;

    set(handles.pushbutton1,'Enable','off');
    set(handles.pushbutton1,'Visible','off');

    guidata(hObject, handles);
    pause(3);  % wait 5 seconds before first stimulus
    HideCursor();

    while (handles.count <= length(handles.newfilecell))

        handles.VCV = zeros(2,Fs*2);

        handles.filename = strcat('r8b_',handles.newfilecell{handles.count,1});
        sig = wavread(strcat('C:\Users\user\Documents\MATLAB\Neuro-Compensator\vcv\stim\',handles.filename));
        handles.SNR = handles.newfilecell{handles.count,2};

        % get random noise sample
        r = randi([1,232],1);
        babsample = handles.bab(r*Fs:(r+2)*Fs-1);

        % make equal length CVC sample
        r = randi([600,1000],1);
        newsig = zeros(Fs*2,1);
        newsig(r/1000*Fs:(r/1000*Fs+length(sig)-1)) = sig;

        % stitch the samples together and play
        handles.VCV(1,:) = newsig;
        handles.VCV(2,:) = babsample;
        %handles.VCV(2,:) = 0;

        % add 50ms extra to prevent cutoff of sound
        handles.VCV(1,end+1:end+800) = 0;
        handles.VCV(2,end+1:end+800) = 0;

        % create onset/offset ramp for noise (100ms)
        mult = sin([0:0.1*Fs-1]*(pi/2)*(1/0.1*Fs));
        handles.VCV(2,1:0.1*Fs) = handles.VCV(2,1:0.1*Fs).*mult;
        mult = cos([0:0.1*Fs-1]*(pi/2)*(1/0.1*Fs));
        handles.VCV(2,1.9*Fs+1:2*Fs) = handles.VCV(2,1.9*Fs+1:2*Fs).*mult;

        % set attenuation levels
        if handles.SNR == 5
            handles.PA5x2.SetAtten(17);
        else
            handles.PA5x2.SetAtten(120);
        end

        guidata(hObject, handles);

        % play sound, wait until it's done
        Snd('Play', handles.VCV, Fs);
        Snd('Wait');

        enable_buttons(handles);

        % allow user to respond
        while clicked == 0
            pause(0.01);
        end

        if mod(handles.count,42) == 0
            if handles.count ~= 252
                clicked = 0;
                display_break(handles);
                while clicked == 0
                    pause(0.01);
                end
            end
        end

        disable_buttons(handles);

        clicked = 0;
        handles.count = handles.count+1;
        pause(1);  % 1 second ISI

        % update gui variables
        guidata(hObject, handles);

    end

    display_ending(handles);
    
catch
    
    errmsg = lasterr
    disp 'ERROR: Main experiment ended prematurely.'
    ShowCursor();
    return
    
end


% --- Call this function at the very end of the experiment.
function display_ending(handles)

set(handles.pushbutton13,'Visible','off');
set(handles.pushbutton14,'Visible','off');
set(handles.pushbutton15,'Visible','off');
set(handles.pushbutton16,'Visible','off');
set(handles.pushbutton17,'Visible','off');
set(handles.pushbutton18,'Visible','off');
set(handles.pushbutton19,'Visible','off');
set(handles.pushbutton20,'Visible','off');
set(handles.pushbutton21,'Visible','off');
set(handles.pushbutton22,'Visible','off');
set(handles.pushbutton23,'Visible','off');
set(handles.pushbutton24,'Visible','off');
set(handles.pushbutton25,'Visible','off');
set(handles.pushbutton26,'Visible','off');
set(handles.pushbutton27,'Visible','off');
set(handles.pushbutton28,'Visible','off');
set(handles.pushbutton29,'Visible','off');
set(handles.pushbutton30,'Visible','off');
set(handles.pushbutton31,'Visible','off');
set(handles.pushbutton32,'Visible','off');
set(handles.pushbutton33,'Visible','off');
    
set(handles.text1,'Visible','off');
set(handles.text2,'Visible','off');
set(handles.text3,'Visible','off');
set(handles.text4,'Visible','off');
set(handles.text5,'Visible','off');
set(handles.text6,'Visible','off');
set(handles.text7,'Visible','off');
set(handles.text8,'Visible','off');
set(handles.text9,'Visible','off');
set(handles.text10,'Visible','off');
set(handles.text11,'Visible','off');
set(handles.text12,'Visible','off');
set(handles.text13,'Visible','off');
set(handles.text14,'Visible','off');
set(handles.text15,'Visible','off');
set(handles.text16,'Visible','off');
set(handles.text17,'Visible','off');
set(handles.text18,'Visible','off');
set(handles.text19,'Visible','off');
set(handles.text20,'Visible','off');
set(handles.text21,'Visible','off');
    
set(handles.text22,'String','You have completed the experiment!');
set(handles.text22,'Visible','on');
ShowCursor();
    
    
% --- Prevents activeX squares from obscuring the response interface.
function hide_activeX_controls(handles)

handles.RP2.move([-300 -300 100 100]);
handles.RV8.move([-300 -300 100 100]); 
handles.PA5x1.move([-300 -300 100 100]);
handles.PA5x2.move([-300 -300 100 100]);


function display_break(handles)

set(handles.pushbutton13,'Visible','off');
set(handles.pushbutton14,'Visible','off');
set(handles.pushbutton15,'Visible','off');
set(handles.pushbutton16,'Visible','off');
set(handles.pushbutton17,'Visible','off');
set(handles.pushbutton18,'Visible','off');
set(handles.pushbutton19,'Visible','off');
set(handles.pushbutton20,'Visible','off');
set(handles.pushbutton21,'Visible','off');
set(handles.pushbutton22,'Visible','off');
set(handles.pushbutton23,'Visible','off');
set(handles.pushbutton24,'Visible','off');
set(handles.pushbutton25,'Visible','off');
set(handles.pushbutton26,'Visible','off');
set(handles.pushbutton27,'Visible','off');
set(handles.pushbutton28,'Visible','off');
set(handles.pushbutton29,'Visible','off');
set(handles.pushbutton30,'Visible','off');
set(handles.pushbutton31,'Visible','off');
set(handles.pushbutton32,'Visible','off');
set(handles.pushbutton33,'Visible','off');

set(handles.text1,'Visible','off');
set(handles.text2,'Visible','off');
set(handles.text3,'Visible','off');
set(handles.text4,'Visible','off');
set(handles.text5,'Visible','off');
set(handles.text6,'Visible','off');
set(handles.text7,'Visible','off');
set(handles.text8,'Visible','off');
set(handles.text9,'Visible','off');
set(handles.text10,'Visible','off');
set(handles.text11,'Visible','off');
set(handles.text12,'Visible','off');
set(handles.text13,'Visible','off');
set(handles.text14,'Visible','off');
set(handles.text15,'Visible','off');
set(handles.text16,'Visible','off');
set(handles.text17,'Visible','off');
set(handles.text18,'Visible','off');
set(handles.text19,'Visible','off');
set(handles.text20,'Visible','off');
set(handles.text21,'Visible','off');
    
set(handles.pushbutton37,'Visible','on');
set(handles.text22,'Visible','on');


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'aba')) % if correct
    str = strcat(num2str(handles.count), ' resp: aba', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: aba', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'acha')) % if correct
    str = strcat(num2str(handles.count), ' resp: acha', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: acha', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'ada')) % if correct
    str = strcat(num2str(handles.count), ' resp: ada', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: ada', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'afa')) % if correct
    str = strcat(num2str(handles.count), ' resp: afa', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: afa', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'aga')) % if correct % if correct
    str = strcat(num2str(handles.count), ' resp: aga', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: aga', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'aha')) % if correct % if correct
    str = strcat(num2str(handles.count), ' resp: aha', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: aha', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'aka')) % if correct % if correct
    str = strcat(num2str(handles.count), ' resp: aka', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: aka', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'ala')) % if correct
    str = strcat(num2str(handles.count), ' resp: ala', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: ala', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'ama')) % if correct
    str = strcat(num2str(handles.count), ' resp: ama', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: ama', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'ana')) % if correct
    str = strcat(num2str(handles.count), ' resp: ana', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: ana', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'apa')) % if correct
    str = strcat(num2str(handles.count), ' resp: apa', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: apa', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'ara')) % if correct
    str = strcat(num2str(handles.count), ' resp: ara', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: ara', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'asa')) % if correct
    str = strcat(num2str(handles.count), ' resp: asa', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: asa', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton26.
function pushbutton26_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'asha')) % if correct
    str = strcat(num2str(handles.count), ' resp: asha', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: asha', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton27.
function pushbutton27_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'ata')) % if correct
    str = strcat(num2str(handles.count), ' resp: ata', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: ata', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'atha')) % if correct
    str = strcat(num2str(handles.count), ' resp: atha', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: atha', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'ava')) % if correct
    str = strcat(num2str(handles.count), ' resp: ava', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: ava', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton30.
function pushbutton30_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'awa')) % if correct
    str = strcat(num2str(handles.count), ' resp: awa', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: awa', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton31.
function pushbutton31_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'aya')) % if correct
    str = strcat(num2str(handles.count), ' resp: aya', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: aya', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'aza')) % if correct
    str = strcat(num2str(handles.count), ' resp: aza', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: aza', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Executes on button press in pushbutton33.
function pushbutton33_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if ~isempty(findstr(handles.filename, 'azha')) % if correct
    str = strcat(num2str(handles.count), ' resp: azha', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: azha', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
end

clicked = 1;
guidata(hObject, handles);


% --- Disables buttons.
function disable_buttons(handles)

set(handles.pushbutton13,'Enable','off');
set(handles.pushbutton14,'Enable','off');
set(handles.pushbutton15,'Enable','off');
set(handles.pushbutton16,'Enable','off');
set(handles.pushbutton17,'Enable','off');
set(handles.pushbutton18,'Enable','off');
set(handles.pushbutton19,'Enable','off');
set(handles.pushbutton20,'Enable','off');
set(handles.pushbutton21,'Enable','off');
set(handles.pushbutton22,'Enable','off');
set(handles.pushbutton23,'Enable','off');
set(handles.pushbutton24,'Enable','off');
set(handles.pushbutton25,'Enable','off');
set(handles.pushbutton26,'Enable','off');
set(handles.pushbutton27,'Enable','off');
set(handles.pushbutton28,'Enable','off');
set(handles.pushbutton29,'Enable','off');
set(handles.pushbutton30,'Enable','off');
set(handles.pushbutton31,'Enable','off');
set(handles.pushbutton32,'Enable','off');
set(handles.pushbutton33,'Enable','off');


% --- Enables buttons.
function enable_buttons(handles)

set(handles.pushbutton13,'Enable','on');
set(handles.pushbutton14,'Enable','on');
set(handles.pushbutton15,'Enable','on');
set(handles.pushbutton16,'Enable','on');
set(handles.pushbutton17,'Enable','on');
set(handles.pushbutton18,'Enable','on');
set(handles.pushbutton19,'Enable','on');
set(handles.pushbutton20,'Enable','on');
set(handles.pushbutton21,'Enable','on');
set(handles.pushbutton22,'Enable','on');
set(handles.pushbutton23,'Enable','on');
set(handles.pushbutton24,'Enable','on');
set(handles.pushbutton25,'Enable','on');
set(handles.pushbutton26,'Enable','on');
set(handles.pushbutton27,'Enable','on');
set(handles.pushbutton28,'Enable','on');
set(handles.pushbutton29,'Enable','on');
set(handles.pushbutton30,'Enable','on');
set(handles.pushbutton31,'Enable','on');
set(handles.pushbutton32,'Enable','on');
set(handles.pushbutton33,'Enable','on');


% --- Executes on button press in pushbutton37.
function pushbutton37_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

set(handles.pushbutton37,'Visible','off');
set(handles.text22,'Visible','off');

set(handles.pushbutton13,'Visible','on');
set(handles.pushbutton14,'Visible','on');
set(handles.pushbutton15,'Visible','on');
set(handles.pushbutton16,'Visible','on');
set(handles.pushbutton17,'Visible','on');
set(handles.pushbutton18,'Visible','on');
set(handles.pushbutton19,'Visible','on');
set(handles.pushbutton20,'Visible','on');
set(handles.pushbutton21,'Visible','on');
set(handles.pushbutton22,'Visible','on');
set(handles.pushbutton23,'Visible','on');
set(handles.pushbutton24,'Visible','on');
set(handles.pushbutton25,'Visible','on');
set(handles.pushbutton26,'Visible','on');
set(handles.pushbutton27,'Visible','on');
set(handles.pushbutton28,'Visible','on');
set(handles.pushbutton29,'Visible','on');
set(handles.pushbutton30,'Visible','on');
set(handles.pushbutton31,'Visible','on');
set(handles.pushbutton32,'Visible','on');
set(handles.pushbutton33,'Visible','on');

set(handles.text1,'Visible','on');
set(handles.text2,'Visible','on');
set(handles.text3,'Visible','on');
set(handles.text4,'Visible','on');
set(handles.text5,'Visible','on');
set(handles.text6,'Visible','on');
set(handles.text7,'Visible','on');
set(handles.text8,'Visible','on');
set(handles.text9,'Visible','on');
set(handles.text10,'Visible','on');
set(handles.text11,'Visible','on');
set(handles.text12,'Visible','on');
set(handles.text13,'Visible','on');
set(handles.text14,'Visible','on');
set(handles.text15,'Visible','on');
set(handles.text16,'Visible','on');
set(handles.text17,'Visible','on');
set(handles.text18,'Visible','on');
set(handles.text19,'Visible','on');
set(handles.text20,'Visible','on');
set(handles.text21,'Visible','on');

clicked = 1;
