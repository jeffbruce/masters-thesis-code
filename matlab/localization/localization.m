function varargout = localization(varargin)
% LOCALIZATION M-file for localization.fig
%      LOCALIZATION, by itself, creates a new LOCALIZATION or raises the existing
%      singleton*.
%
%      H = LOCALIZATION returns the handle to a new LOCALIZATION or the handle to
%      the existing singleton*.
%
%      LOCALIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOCALIZATION.M with the given input arguments.
%
%      LOCALIZATION('Property','Value',...) creates a new LOCALIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before localization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to localization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help localization

% Last Modified by GUIDE v2.5 12-Sep-2011 19:37:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @localization_OpeningFcn, ...
                   'gui_OutputFcn',  @localization_OutputFcn, ...
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


% --- Executes just before localization is made visible.
function localization_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to localization (see VARARGIN)

global clicked;

% Choose default command line output for localization
handles.output = hObject;

% load circuits and assign to handle variables
[RP2,RV8,PA5x1,PA5x2] = load_circuits_loc(varargin{1});
handles.RP2 = RP2;
handles.RV8 = RV8;
handles.PA5x1 = PA5x1;
handles.PA5x2 = PA5x2;

% init and randomize stimuli
[randstimuli] = init_localization(varargin{1});
handles.randstimuli = randstimuli;
handles.count = 1;

% acquire subject name, open file ID
handles.subjname = input('Input subject name: ','s');
if varargin{1} == 1
    handles.fileID = fopen(strcat('C:\Users\user\Documents\MATLAB\Neuro-Compensator\localization\data\','low\',handles.subjname,'.txt'), 'w');
else
    handles.fileID = fopen(strcat('C:\Users\user\Documents\MATLAB\Neuro-Compensator\localization\data\','high\',handles.subjname,'.txt'), 'w');
end
fprintf(handles.fileID, '%s \r\n', strcat('trial', [' ' 'Hz'], [' ' 'speaker'], [' ' 'x'] ,[' ' 'y'] ,[' ' 'angle']));

% init clicked
clicked = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes localization wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = localization_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in continuebtn.
function continuebtn_Callback(hObject, eventdata, handles)
% hObject    handle to continuebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

set(handles.continuebtn,'Visible','off');
set(handles.text1,'Visible','off');
set(handles.continuebtn,'Enable','off');
set(handles.text1,'Enable','off');

% read in image
imageArray = imread('C:\Users\user\Documents\MATLAB\Neuro-Compensator\localization\response_interface.jpg');
% Switch active axes to the one you made for the image.
axes(handles.axesImage);
% Put the image array into the axes so it will appear on the GUI
imshow(imageArray, 'Border', 'tight');

guidata(hObject, handles);

pause(5);  % 5 seconds before first presentation.

Fs = 44100;

while (handles.count <= length(handles.randstimuli))
    
    clicked = 0;
    handles.stim = handles.randstimuli(handles.count, :);
    
    % create 1/3 octave band
    whitenz = randn(1,8820);  %200ms duration
    [B,A] = oct3dsgn(handles.stim(1),Fs,4);
    y = filter(B,A,whitenz);  % apply oct band filter    
    y(1:2205) = sin([0:2204]*pi/4409).*y(1:2205);  % apply 50ms rise/fall
    y(6616:8820) = cos([0:2204]*pi/4409).*y(6616:8820);  % apply 50ms rise/fall
    y(8821:11025) = 0;  % add 50 ms to prevent click
    
    %analyze_this(y);
    
    % switch speaker
    er = handles.RV8.SetTagVal('Speaker', handles.stim(2));
    if er
    else
        Disp('Error setting RV8 Tag');
    end
    handles.RV8.SoftTrg (1);
    
    % play sound
    Snd('Play', y, Fs);
    Snd('Wait');
    
    % switch speaker
    er = handles.RV8.SetTagVal('Speaker', 0);
    if er
    else
        Disp('Error setting RV8 Tag');
    end
    handles.RV8.SoftTrg (1);
    
    guidata(hObject, handles);
    while clicked == 0
        pause(0.01);
    end
    
    handles.count = handles.count + 1;
    pause(2);
    
    guidata(hObject, handles);
    
end

% Update handles structure
guidata(hObject, handles);


% --- Helper function to examine waveform and spectrum.
function analyze_this(y)

figure(1); plot(1:8820, y); title('Waveform');
    
yfft = fft(y);
yabs = abs(yfft);

figure(2); plot((0:5:8315),yabs(1:1664)); title('Spectrum');


% --- Executes on mouse press over figure background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

pos=get(hObject,'CurrentPoint');

% if they click outside the axes, have them click again.
if ((pos(1) <= 137.8) && (pos(2) <= 52.6))

YLim = get(handles.axesImage, 'YLim');
YLim = YLim(2);
coordinates = get(handles.axesImage, 'CurrentPoint');

x = coordinates(1,1);
y = coordinates(1,2);

if y < (YLim/2)
    y = YLim - y;
else
    y = (YLim/2) - (y - YLim/2);
end

angle = radtodeg(atan(y/x));

if clicked == 0
    fprintf(handles.fileID, strcat(num2str(handles.count), [' ' num2str(handles.stim(1))], [' ' num2str(handles.stim(2))], [' ' num2str(x)], [' ' num2str(y)],  [' ' num2str(angle)], '\r\n'));
end

clicked = 1;

end

guidata(hObject, handles);
