function varargout = run_aided_audiogram_tone(varargin)
% RUN_AIDED_AUDIOGRAM_TONE M-file for run_aided_audiogram_tone.fig
%      RUN_AIDED_AUDIOGRAM_TONE, by itself, creates a new RUN_AIDED_AUDIOGRAM_TONE or raises the existing
%      singleton*.
%
%      H = RUN_AIDED_AUDIOGRAM_TONE returns the handle to a new RUN_AIDED_AUDIOGRAM_TONE or the handle to
%      the existing singleton*.
%
%      RUN_AIDED_AUDIOGRAM_TONE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUN_AIDED_AUDIOGRAM_TONE.M with the given input arguments.
%
%      RUN_AIDED_AUDIOGRAM_TONE('Property','Value',...) creates a new RUN_AIDED_AUDIOGRAM_TONE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before run_aided_audiogram_tone_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to run_aided_audiogram_tone_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help run_aided_audiogram_tone

% Last Modified by GUIDE v2.5 29-Jan-2012 13:41:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @run_aided_audiogram_tone_OpeningFcn, ...
                   'gui_OutputFcn',  @run_aided_audiogram_tone_OutputFcn, ...
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


% --- Executes just before run_aided_audiogram_tone is made visible.
function run_aided_audiogram_tone_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to run_aided_audiogram_tone (see VARARGIN)

% Choose default command line output for run_aided_audiogram_tone
handles.output = hObject;

[RP2,RV8,PA5x1,PA5x2] = load_circuits_audiogram();
handles.RP2 = RP2;
handles.RV8 = RV8;
handles.PA5x1 = PA5x1;
handles.PA5x2 = PA5x2;

handles.resp = 0;
handles.clicked = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes run_aided_audiogram_tone wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = run_aided_audiogram_tone_OutputFcn(hObject, eventdata, handles) 
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

handles.resp = 1;
handles.clicked = 1;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.resp = 2;
handles.clicked = 1;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pushbutton3,'Visible','off');
set(handles.text2,'Visible','off');

set(handles.pushbutton1,'Enable','on');
set(handles.pushbutton1,'Visible','on');
set(handles.pushbutton2,'Enable','on');
set(handles.pushbutton2,'Visible','on');

handles.midway = handles.midway + 1;

% Update handles structure
guidata(hObject, handles);

if handles.midway < 1

    % Call main experiment when instructions are understood
    gapdetectionnoise(hObject, handles);

end
