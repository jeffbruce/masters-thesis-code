function varargout = loc_laser_left(varargin)
% loc_laser_left M-file for loc_laser_left.fig
%      loc_laser_left, by itself, creates a new loc_laser_left or raises the existing
%      singleton*.
%
%      H = loc_laser_left returns the handle to a new loc_laser_left or the handle to
%      the existing singleton*.
%
%      loc_laser_left('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in loc_laser_left.M with the given input arguments.
%
%      loc_laser_left('Property','Value',...) creates a new loc_laser_left or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before loc_laser_left_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to loc_laser_left_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help loc_laser_left

% Last Modified by GUIDE v2.5 23-Mar-2012 13:06:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @loc_laser_left_OpeningFcn, ...
                   'gui_OutputFcn',  @loc_laser_left_OutputFcn, ...
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


%%% INITIALIZATION

% --- Executes just before loc_laser_left is made visible.
function loc_laser_left_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to loc_laser_left (see VARARGIN)

% Choose default command line output for loc_laser_left
handles.output = hObject;

% load circuits and assign to handle variables
%[RP2,RV8,PA5x1,PA5x2] = load_circuits_loc(varargin{1});
%handles.RP2 = RP2;
%handles.RV8 = RV8;
%handles.PA5x1 = PA5x1;
%handles.PA5x2 = PA5x2;
% eliminate distraction: hide activeX controls from view
%hide_activeX_controls(handles);

% init and randomize stimuli
[randstimuli] = init_localization(varargin{1});
handles.randstimuli = randstimuli;
handles.count = 1;

% get filepath so files can be saved to this directory automatically
entirepath = mfilename('fullpath');
filename = mfilename();
handles.filepath = entirepath(1:end-length(filename));

% read in telephone test sample
handles.t3 = wavread(strcat(handles.filepath, 'TELEPHON1.wav'));

% acquire subject name, open file ID
handles.subjname = input('Input subject name: ','s');
if varargin{1} == 1
    handles.fileID = fopen(strcat(handles.filepath,'data\left\','phone\',handles.subjname,'.txt'), 'w');
elseif varargin{1} == 2
    handles.fileID = fopen(strcat(handles.filepath,'data\left\','low\',handles.subjname,'.txt'), 'w');
elseif varargin{1} == 3
    handles.fileID = fopen(strcat(handles.filepath,'data\left\','high\',handles.subjname,'.txt'), 'w');
else
    err = 'You must input one of 1, 2, or 3 as an argument to the function.'
end
fprintf(handles.fileID, '%s \r\n', strcat('trial', [' ' 'Hz'], [' ' 'speaker'], [' ' 'resp'], [' ' 'angle']));

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = loc_laser_left_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%% PLAYS A SOUND

% --- Executes on button press in playbtn.
function playbtn_Callback(hObject, eventdata, handles)
% hObject    handle to playbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.count <= length(handles.randstimuli)
    
    disable_play(handles); 
    Fs = 44100;

    handles.stim = handles.randstimuli(handles.count, :);

    % phone stim
    if handles.randstimuli(handles.count,1) == -1
        y = handles.t3;
        y = y';
    else  % low or high freq stim
        % create 200ms 1/3 octave band
        % high freq is 67-68 dB SPL CF
        % low freq is 65-70 dB SPL CF
        whitenz = randn(1,8820);  %200ms duration
        [B,A] = oct3dsgn(handles.stim(1),Fs,4);
        y = filter(B,A,whitenz);  % apply oct band filter    
        y(1:2205) = sin([0:2204]*pi/4409).*y(1:2205);  % apply 50ms rise
        y(6616:8820) = cos([0:2204]*pi/4409).*y(6616:8820);  % apply 50ms fall
        y(8821:11025) = 0;  % add 50 ms to prevent click
    end
            
    %analyze_this(y);

    % switch speaker
    %er = handles.RV8.SetTagVal('Speaker', handles.stim(2));
    %if er
    %else
    %    Disp('Error setting RV8 Tag');
    %end
    %handles.RV8.SoftTrg (1);

    % play sound
    Snd('Play', y, Fs);
    Snd('Wait');

    enable_responses(handles);

    % switch speaker
    %er = handles.RV8.SetTagVal('Speaker', 0);
    %if er
    %else
    %    Disp('Error setting RV8 Tag');
    %end
    %handles.RV8.SoftTrg (1);

    handles.count = handles.count + 1;

    guidata(hObject, handles);

else  % no more sounds remaining
    
    disable_play(handles);
    fclose(handles.fileID);
    ShowCursor();
    return;
    
end


%%% BUTTON CALLBACKS

% --- Executes on button press in pushbuttonA.
function pushbuttonA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enable_play(handles);
disable_responses(handles);
resp = 1;
fprintf(handles.fileID, strcat(num2str(handles.count), [' ' num2str(handles.stim(1))], [' ' num2str(handles.stim(2))], [' ' num2str(resp)], [' ' num2str(15*(resp-1))], '\r\n'));

% --- Executes on button press in pushbuttonB.
function pushbuttonB_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enable_play(handles);
disable_responses(handles);
resp = 2;
fprintf(handles.fileID, strcat(num2str(handles.count), [' ' num2str(handles.stim(1))], [' ' num2str(handles.stim(2))], [' ' num2str(resp)], [' ' num2str(15*(resp-1))], '\r\n'));

% --- Executes on button press in pushbuttonC.
function pushbuttonC_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enable_play(handles);
disable_responses(handles);
resp = 3;
fprintf(handles.fileID, strcat(num2str(handles.count), [' ' num2str(handles.stim(1))], [' ' num2str(handles.stim(2))], [' ' num2str(resp)], [' ' num2str(15*(resp-1))], '\r\n'));

% --- Executes on button press in pushbuttonD.
function pushbuttonD_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enable_play(handles);
disable_responses(handles);
resp = 4;
fprintf(handles.fileID, strcat(num2str(handles.count), [' ' num2str(handles.stim(1))], [' ' num2str(handles.stim(2))], [' ' num2str(resp)], [' ' num2str(15*(resp-1))], '\r\n'));

% --- Executes on button press in pushbuttonE.
function pushbuttonE_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enable_play(handles);
disable_responses(handles);
resp = 5;
fprintf(handles.fileID, strcat(num2str(handles.count), [' ' num2str(handles.stim(1))], [' ' num2str(handles.stim(2))], [' ' num2str(resp)], [' ' num2str(15*(resp-1))], '\r\n'));

% --- Executes on button press in pushbuttonF.
function pushbuttonF_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enable_play(handles);
disable_responses(handles);
resp = 6;
fprintf(handles.fileID, strcat(num2str(handles.count), [' ' num2str(handles.stim(1))], [' ' num2str(handles.stim(2))], [' ' num2str(resp)], [' ' num2str(15*(resp-1))], '\r\n'));

% --- Executes on button press in pushbuttonG.
function pushbuttonG_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
enable_play(handles);
disable_responses(handles);
resp = 7;
fprintf(handles.fileID, strcat(num2str(handles.count), [' ' num2str(handles.stim(1))], [' ' num2str(handles.stim(2))], [' ' num2str(resp)], [' ' num2str(15*(resp-1))], '\r\n'));


%%% ENABLE/DISABLE BUTTONS

function disable_play(handles)
set(handles.playbtn,'Enable','off');

function enable_play(handles)
set(handles.playbtn,'Enable','on');

function disable_responses(handles)
set(handles.pushbuttonA,'Enable','off');
set(handles.pushbuttonB,'Enable','off');
set(handles.pushbuttonC,'Enable','off');
set(handles.pushbuttonD,'Enable','off');
set(handles.pushbuttonE,'Enable','off');
set(handles.pushbuttonF,'Enable','off');
set(handles.pushbuttonG,'Enable','off');

function enable_responses(handles)
set(handles.pushbuttonA,'Enable','on');
set(handles.pushbuttonB,'Enable','on');
set(handles.pushbuttonC,'Enable','on');
set(handles.pushbuttonD,'Enable','on');
set(handles.pushbuttonE,'Enable','on');
set(handles.pushbuttonF,'Enable','on');
set(handles.pushbuttonG,'Enable','on');


%%% HELPER FUNCTIONS - PLOT SPECTRUM AND HIDE OBJECTS

% --- Helper function to examine waveform and spectrum.
function analyze_this(y)

figure(1); plot(1:8820, y); title('Waveform');
    
yfft = fft(y);
yabs = abs(yfft);

figure(2); plot((0:5:8315),yabs(1:1664)); title('Spectrum');

% --- Prevents activeX squares from obscuring the response interface.
function hide_activeX_controls(handles)

handles.RP2.move([-300 -300 100 100]);
handles.RV8.move([-300 -300 100 100]); 
handles.PA5x1.move([-300 -300 100 100]);
handles.PA5x2.move([-300 -300 100 100]); 
