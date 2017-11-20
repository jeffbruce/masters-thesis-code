function varargout = hVd(varargin)
% HVD M-file for hVd.fig
%      HVD, by itself, creates a new HVD or raises the existing
%      singleton*.
%
%      H = HVD returns the handle to a new HVD or the handle to
%      the existing singleton*.
%
%      HVD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HVD.M with the given input arguments.
%
%      HVD('Property','Value',...) creates a new HVD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hVd_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hVd_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hVd

% Last Modified by GUIDE v2.5 22-Oct-2011 11:17:05

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hVd_OpeningFcn, ...
                   'gui_OutputFcn',  @hVd_OutputFcn, ...
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



% --- Executes just before hVd is made visible.
function hVd_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hVd (see VARARGIN)

global clicked;

% Choose default command line output for hVd
handles.output = hObject;

[RP2,RV8,PA5x1,PA5x2] = load_circuits_hVd();

handles.RP2 = RP2;
handles.RV8 = RV8;
handles.PA5x1 = PA5x1;
handles.PA5x2 = PA5x2;

[newfilecell,bab,Fs,depth] = init_hVd();

handles.subjname = input('Input subject name: ','s');
handles.fileID = fopen(strcat('C:\Users\user\Documents\MATLAB\Neuro-Compensator\hVd\data\',handles.subjname,'.txt'), 'w');

handles.newfilecell = newfilecell;
handles.bab = bab;
handles.Fs = Fs;
handles.depth = depth;
handles.count = 1;
handles.vowel = '';

clicked = 0;

hide_activeX_controls(handles);
disable_buttons(handles);

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes hVd wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = hVd_OutputFcn(hObject, eventdata, handles) 
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
    pause(3);  % wait 3 seconds before first stimulus
    HideCursor();

    while (handles.count <= length(handles.newfilecell))

        handles.CVC = zeros(2,Fs*2);

        handles.filename = handles.newfilecell{handles.count,1};
        sig = wavread(strcat('C:\Users\user\Documents\MATLAB\Neuro-Compensator\hVd\stim\',handles.filename));
        handles.SNR = handles.newfilecell{handles.count,2};
        handles.curtoken = handles.newfilecell{handles.count}(4:5);

        % get random noise sample
        r = randi([1,232],1);
        babsample = handles.bab(r*Fs:(r+2)*Fs-1);

        % make equal length CVC sample
        r = randi([600,1000],1);
        newsig = zeros(Fs*2,1);
        newsig(r/1000*Fs:(r/1000*Fs+length(sig)-1)) = sig;

        % stitch the samples together and play
        handles.CVC(1,:) = newsig;
        handles.CVC(2,:) = babsample;

        % add 50ms extra to prevent cutoff of sound
        handles.CVC(1,end+1:end+800) = 0;
        handles.CVC(2,end+1:end+800) = 0;

        % create onset/offset ramp for noise (100ms)
        mult = sin([0:0.1*Fs-1]*(pi/2)*(1/0.1*Fs));
        handles.CVC(2,1:0.1*Fs) = handles.CVC(2,1:0.1*Fs).*mult;
        mult = cos([0:0.1*Fs-1]*(pi/2)*(1/0.1*Fs));
        handles.CVC(2,1.9*Fs+1:2*Fs) = handles.CVC(2,1.9*Fs+1:2*Fs).*mult;

        % set attenuation levels
        if handles.SNR == 5
            handles.PA5x2.SetAtten(17);
        else  % no noise
            handles.PA5x2.SetAtten(120);
        end

        guidata(hObject, handles);

        % play sound, wait until it's done
        Snd('Play', handles.CVC, Fs);
        Snd('Wait');

        enable_buttons(handles);

        % allow user to respond
        while clicked == 0
            pause(0.01);
        end

        % allow break after every block
        if mod(handles.count,44) == 0
            if handles.count ~= 220
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
    
    set(handles.text1,'String','You have completed the experiment!');
    set(handles.text1,'Visible','on');
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
    
set(handles.pushbutton27,'Visible','on');
set(handles.text1,'Visible','on');


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

if strcmp(handles.curtoken, 'ae') % if correct
    str = strcat(num2str(handles.count), ' resp: ae', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: ae', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
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

if strcmp(handles.curtoken, 'aw') % if correct
    str = strcat(num2str(handles.count), ' resp: aw', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: aw', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
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

if strcmp(handles.curtoken, 'eh') % if correct
    str = strcat(num2str(handles.count), ' resp: eh', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: eh', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
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

if strcmp(handles.curtoken, 'ei') % if correct
    str = strcat(num2str(handles.count), ' resp: ei', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: ei', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
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

if strcmp(handles.curtoken, 'er') % if correct
    str = strcat(num2str(handles.count), ' resp: er', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: er', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
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

if strcmp(handles.curtoken, 'ih') % if correct
    str = strcat(num2str(handles.count), ' resp: ih', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: ih', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
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

if strcmp(handles.curtoken, 'iy') % if correct
    str = strcat(num2str(handles.count), ' resp: iy', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: iy', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
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

if strcmp(handles.curtoken, 'oa') % if correct
    str = strcat(num2str(handles.count), ' resp: oa', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: oa', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
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

if strcmp(handles.curtoken, 'oo') % if correct
    str = strcat(num2str(handles.count), ' resp: oo', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: oo', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
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

if strcmp(handles.curtoken, 'uh') % if correct
    str = strcat(num2str(handles.count), ' resp: uh', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: uh', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
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

if strcmp(handles.curtoken, 'uw') % if correct
    str = strcat(num2str(handles.count), ' resp: uw', [' ' handles.filename], ' correct', [' ' num2str(handles.SNR)]);
    fprintf(handles.fileID, '%s \r\n', str);
else  % else incorrect
    str = strcat(num2str(handles.count), ' resp: uw', [' ' handles.filename], ' incorrect', [' ' num2str(handles.SNR)]);
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

set(handles.pushbutton27,'Visible','off');
set(handles.text1,'Visible','off');

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

clicked = 1;


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
