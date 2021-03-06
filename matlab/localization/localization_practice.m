function varargout = localization_practice(varargin)
% LOCALIZATION_PRACTICE M-file for localization_practice.fig
%      LOCALIZATION_PRACTICE, by itself, creates a new LOCALIZATION_PRACTICE or raises the existing
%      singleton*.
%
%      H = LOCALIZATION_PRACTICE returns the handle to a new LOCALIZATION_PRACTICE or the handle to
%      the existing singleton*.
%
%      LOCALIZATION_PRACTICE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOCALIZATION_PRACTICE.M with the given input arguments.
%
%      LOCALIZATION_PRACTICE('Property','Value',...) creates a new LOCALIZATION_PRACTICE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before localization_practice_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to localization_practice_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help localization_practice

% Last Modified by GUIDE v2.5 23-Oct-2011 14:09:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @localization_practice_OpeningFcn, ...
                   'gui_OutputFcn',  @localization_practice_OutputFcn, ...
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


% --- Executes just before localization_practice is made visible.
function localization_practice_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to localization_practice (see VARARGIN)

global clicked;

% Choose default command line output for localization_practice
handles.output = hObject;

% load circuits and assign to handle variables
[RP2,RV8,PA5x1,PA5x2] = load_circuits_loc(varargin{1});
handles.RP2 = RP2;
handles.RV8 = RV8;
handles.PA5x1 = PA5x1;
handles.PA5x2 = PA5x2;
hide_activeX_controls(handles);

% init and randomize stimuli
[randstimuli] = init_localization(varargin{1});
randstimuli(1,2) = 7;
randstimuli(2,2) = 1;
randstimuli(3,2) = round(rand(1)*2) + 3;
handles.randstimuli = randstimuli;
handles.count = 1;

% acquire subject name, open file ID
handles.subjname = input('Input subject name: ','s');
if varargin{1} == 1
    handles.fileID = fopen(strcat('C:\Users\user\Documents\MATLAB\Neuro-Compensator\localization\practice data\',handles.subjname,'.txt'), 'w');
else
    handles.fileID = fopen(strcat('C:\Users\user\Documents\MATLAB\Neuro-Compensator\localization\practice data\',handles.subjname,'.txt'), 'w');
end
fprintf(handles.fileID, '%s \r\n', strcat('trial', [' ' 'Hz'], [' ' 'speaker'], [' ' 'x'] ,[' ' 'y'] ,[' ' 'angle']));

% init clicked
clicked = 1;

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = localization_practice_OutputFcn(hObject, eventdata, handles) 
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

try

    global clicked;

    set(handles.continuebtn,'Enable','off');
    set(handles.continuebtn,'Visible','off');
    set(handles.text1,'Visible','off');

    % read in image
    imageArray = imread('C:\Users\user\Documents\MATLAB\Neuro-Compensator\localization\response_interface_right.jpg');
    imageArray2 = imread('C:\Users\user\Documents\MATLAB\Neuro-Compensator\localization\response_zone_right.jpg');
    % Switch active axes to the one you made for the image.
    axes(handles.axesImage);
    % Put the image array into the axes so it will appear on the GUI
    imshow(imageArray, 'Border', 'tight');

    guidata(hObject, handles);

    Fs = 44100;

    % 2 secs between practice trials
    HideCursor();
    pause(2);

    handles.stim = handles.randstimuli(handles.count, :);

    % create 1/3 octave band
    whitenz = randn(1,8820);  %200ms duration
    [B,A] = oct3dsgn(handles.stim(1),Fs,4);
    y = filter(B,A,whitenz);  % apply oct band filter    
    y(1:2205) = sin([0:2204]*pi/4409).*y(1:2205);  % apply 50ms rise/fall
    y(6616:8820) = cos([0:2204]*pi/4409).*y(6616:8820);  % apply 50ms rise/fall
    y(8821:11025) = 0;  % add 50 ms to prevent click

    % switch speaker
    er = handles.RV8.SetTagVal('Speaker', handles.stim(2));
    if er
    else
        Disp('Error setting RV8 Tag');
    end
    handles.RV8.SoftTrg (1);

    imshow(imageArray2, 'Border', 'tight');

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

    clicked = 0;
    guidata(hObject, handles);
    while clicked == 0
        pause(0.01);
    end

    imshow(imageArray, 'Border', 'tight');

    cla;
    if handles.count == 1
        set(handles.text1,'String','The next sound will come from the far left.');
        set(handles.text1,'Visible','on');
        set(handles.continuebtn,'Enable','on');
        set(handles.continuebtn,'Visible','on');
    elseif handles.count == 2
        set(handles.text1,'String','The next sound will come from somewhere in the middle.');
        set(handles.text1,'Visible','on');
        set(handles.continuebtn,'Enable','on');
        set(handles.continuebtn,'Visible','on');
    else
        display_ending(handles);
    end

    handles.count = handles.count + 1;

    guidata(hObject, handles);

catch
    
    errmsg = lasterr
    disp 'ERROR: Practice session ended prematurely.'
    ShowCursor();
    return
    
end


function display_ending(handles)
    
cla
set(handles.text1,'String','You have completed the practice session.');
set(handles.text1,'Visible','on');
ShowCursor();


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


% --- Executes on mouse press over figure background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

pos=get(hObject,'CurrentPoint');

% subject must respond within the axes
if (pos(1) <= 101.2) && (pos(2) >= 14.15) && (clicked == 0)

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

    XLim = get(handles.axesImage, 'XLim');
    XLim = XLim(2);
    x = XLim - x;
    
    radius = sqrt(y^2 + x^2);

    % subject must respond within 50 pixels of arc
    if (radius >= 350 && radius <= 450)

        angle = radtodeg(atan(y/x));

        if clicked == 0
            fprintf(handles.fileID, strcat(num2str(handles.count), [' ' num2str(handles.stim(1))], [' ' num2str(handles.stim(2))], [' ' num2str(x)], [' ' num2str(y)],  [' ' num2str(angle)], '\r\n'));
        end

        clicked = 1;
        
    end

end

guidata(hObject, handles);
