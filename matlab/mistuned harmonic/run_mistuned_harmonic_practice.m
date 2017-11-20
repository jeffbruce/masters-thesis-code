function varargout = run_mistuned_harmonic_practice(varargin)
% RUN_MISTUNED_HARMONIC_PRACTICE M-file for run_mistuned_harmonic_practice.fig
%      RUN_MISTUNED_HARMONIC_PRACTICE, by itself, creates a new RUN_MISTUNED_HARMONIC_PRACTICE or raises the existing
%      singleton*.
%
%      H = RUN_MISTUNED_HARMONIC_PRACTICE returns the handle to a new RUN_MISTUNED_HARMONIC_PRACTICE or the handle to
%      the existing singleton*.
%
%      RUN_MISTUNED_HARMONIC_PRACTICE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RUN_MISTUNED_HARMONIC_PRACTICE.M with the given input arguments.
%
%      RUN_MISTUNED_HARMONIC_PRACTICE('Property','Value',...) creates a new RUN_MISTUNED_HARMONIC_PRACTICE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before run_mistuned_harmonic_practice_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to run_mistuned_harmonic_practice_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help run_mistuned_harmonic_practice

% Last Modified by GUIDE v2.5 26-Jan-2012 16:54:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @run_mistuned_harmonic_practice_OpeningFcn, ...
                   'gui_OutputFcn',  @run_mistuned_harmonic_practice_OutputFcn, ...
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


% --- Executes just before run_mistuned_harmonic_practice is made visible.
function run_mistuned_harmonic_practice_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to run_mistuned_harmonic_practice (see VARARGIN)

% Choose default command line output for run_mistuned_harmonic_practice
handles.output = hObject;

if length(varargin) == 1

    [RP2,RV8,PA5x1,PA5x2] = load_circuits_mistuned();
    handles.RP2 = RP2;
    handles.RV8 = RV8;
    handles.PA5x1 = PA5x1;
    handles.PA5x2 = PA5x2;
    
    handles.resp = 0;
    handles.clicked = 0;
    handles.midway = -1;
    handles.condition = varargin{1};
    
    hide_activeX_controls(handles);
    subjname = input('Input subject name: ', 's');
    handles.fileID = fopen(strcat('C:\Users\user\Documents\MATLAB\Neuro-Compensator\mistuned harmonic\practice data\',num2str(handles.condition),subjname,'.txt'), 'wt');
    fprintf(handles.fileID, 'stair\treversal\tstreak\tlast\tcurfactor\tup\taltered\tresp\tcor?\n');

end

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = run_mistuned_harmonic_practice_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Prevents activeX squares from obscuring the response interface.
function hide_activeX_controls(handles)

handles.RP2.move([-300 -300 100 100]);
handles.RV8.move([-300 -300 100 100]); 
handles.PA5x1.move([-300 -300 100 100]);
handles.PA5x2.move([-300 -300 100 100]); 


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


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.resp = 3;
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

set(handles.pushbutton1,'Enable','off');
set(handles.pushbutton1,'Visible','on');
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton2,'Visible','on');
set(handles.pushbutton4,'Enable','off');
set(handles.pushbutton4,'Visible','on');

handles.midway = handles.midway + 1;

% Update handles structure
guidata(hObject, handles);

if handles.midway < 1

    try
        % Call main experiment when instructions are understood
        mistuned_harmonic_practice(hObject, handles, handles.condition);
    catch
        errmsg = lasterr
        disp 'ERROR: Practice session ended prematurely.'
        ShowCursor();
        return
    end
        
end
