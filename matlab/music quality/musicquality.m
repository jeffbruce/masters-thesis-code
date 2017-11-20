function varargout = musicquality(varargin)
% MUSICQUALITY M-file for musicquality.fig
%      MUSICQUALITY, by itself, creates a new MUSICQUALITY or raises the existing
%      singleton*.
%
%      H = MUSICQUALITY returns the handle to a new MUSICQUALITY or the handle to
%      the existing singleton*.
%
%      MUSICQUALITY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MUSICQUALITY.M with the given input arguments.
%
%      MUSICQUALITY('Property','Value',...) creates a new MUSICQUALITY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before musicquality_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to musicquality_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help musicquality

% Last Modified by GUIDE v2.5 06-Oct-2011 15:32:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @musicquality_OpeningFcn, ...
                   'gui_OutputFcn',  @musicquality_OutputFcn, ...
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


% --- Executes just before musicquality is made visible.
function musicquality_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to musicquality (see VARARGIN)

global clicked;

% Choose default command line output for musicquality
handles.output = hObject;

% load circuits and assign to handle variables
%[RP2,RV8,PA5x1,PA5x2] = load_circuits_musicqual();
%handles.RP2 = RP2;
%handles.RV8 = RV8;
%handles.PA5x1 = PA5x1;
%handles.PA5x2 = PA5x2;

% probably best not to randomize presentation, overcomplicates things
handles.Fs = 44100;
classical1 = '[1] - 03 - Mozart - Piano Sonata in C major, KV 330, III. Allegretto 90sec.wav';
classical2 = '02 Tommy Medley 90sec.wav';
classical3 = '006. Johann Pachelbel - Kanon In D 90sec.wav';
contemp1 = '03 - Superstition 90sec.wav';
contemp2 = '03 - I Guess Thats Why They Call It The Blues 90sec.wav';
contemp3 = '14 Let It Be 90sec.wav';
vocal1 = '08 - They Cant Take That Away From Me 90sec.wav';
vocal2 = 'Mozart - Carmina Burana - O Fortuna 90sec.wav';
vocal3 = '05 - Adeus, Batucada 90sec.wav';

handles.stimuli = cell(9,1);
handles.stimuli{1} = classical1;
handles.stimuli{2} = classical2;
handles.stimuli{3} = classical3;
handles.stimuli{4} = contemp1;
handles.stimuli{5} = contemp2;
handles.stimuli{6} = contemp3;
handles.stimuli{7} = vocal1;
handles.stimuli{8} = vocal2;
handles.stimuli{9} = vocal3;
handles.count = 1;

% acquire subject name, open file ID
handles.pathname = mfilename('fullpath');
handles.pathname = handles.pathname(1:end-12);
handles.subjname = input('Input subject name: ','s');
handles.fileID = fopen(strcat(handles.pathname,'data\',handles.subjname,'.txt'), 'w');
fprintf(handles.fileID, 'file#\tloud\tsharp\tfull\tpleas\tnatur\timpres\r\n');
turn_off_labels(handles);
set_title(handles);

% init clicked
clicked = -1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes musicquality wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = musicquality_OutputFcn(hObject, eventdata, handles) 
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
Fs = handles.Fs;

set(handles.continuebtn,'Visible','off');
set(handles.text1,'Visible','off');
set(handles.continuebtn,'Enable','off');

guidata(hObject, handles);

pause(5);  % 5 seconds before first presentation.

while (handles.count <= length(handles.stimuli))
    
    y = wavread(strcat(handles.pathname, 'stim\', handles.stimuli{handles.count}));
    
    % trim stim to 60 seconds long
    %y = y(1:(Fs*60));
    % apply 10sec sinusoidal fall
    %y(Fs*50+1:Fs*60) = cos([0:(Fs*10-1)]*pi/(2*Fs*10)).*y(Fs*50+1:Fs*60);  
    
    % play sound
    % psych toolbox
    %Snd('Play', y, Fs);  UNCOMMENT IN
    % built-in Matlab
    sound(y, Fs);  % COMMENT OUT
    
    pause(30);
    clicked = 0;
    isPlaying = 1;
    turn_on_labels(handles);  % prompt user with scale after 30 seconds
    
    guidata(hObject, handles);
    while clicked < 6  % || isPlaying ~= 0  % UNCOMMENT IN
        pause(0.01);
        %isPlaying = Snd('IsPlaying');  % UNCOMMENT IN
    end
    
    handles.count = handles.count + 1;
    
    clicked = -1;
    pause(5);  % 5 seconds between finished rating and next stim
    
    guidata(hObject, handles);
    
end

% Update handles structure
guidata(hObject, handles);


function turn_on_labels(handles)

global clicked;

if clicked == 0  % loud

    % read in image
    imageArray = imread(strcat(handles.pathname,'9 point scale.jpg'));
    % Switch active axes to the one you made for the image.
    axes(handles.axesImage);
    % Put the image array into the axes so it will appear on the GUI
    imshow(imageArray, 'Border', 'tight');
    
    set(handles.text1,'String','How loud is the music?');
    set(handles.text7,'String','very quiet');
    set(handles.text8,'String','quiet');
    set(handles.text9,'String','just right');
    set(handles.text10,'String','loud');
    set(handles.text11,'String','very loud');
    
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
    
elseif clicked == 1  % sharp
    
    set(handles.text1,'String','How sharp is the music?');
    set(handles.text7,'String','very smooth');
    set(handles.text8,'String','smooth');
    set(handles.text9,'String','neither sharp nor smooth');
    set(handles.text10,'String','sharp');
    set(handles.text11,'String','very sharp');

elseif clicked == 2  % full
    
    set(handles.text1,'String','How full is the music?');
    set(handles.text7,'String','very thin');
    set(handles.text8,'String','thin');
    set(handles.text9,'String','neither full nor thin');
    set(handles.text10,'String','full');
    set(handles.text11,'String','very full');
    
elseif clicked == 3  % pleas
    
    set(handles.text1,'String','How pleasing is the tonal quality of the music?');
    set(handles.text7,'String','very unpleasant');
    set(handles.text8,'String','unpleasant');
    set(handles.text9,'String','neither pleasant nor unpleasant');
    set(handles.text10,'String','pleasant');
    set(handles.text11,'String','very pleasant');
    
elseif clicked == 4  % natur
    
    set(handles.text1,'String','How natural is the music?');
    set(handles.text7,'String','very unnatural');
    set(handles.text8,'String','unnatural');
    set(handles.text9,'String','neither natural nor unnatural');
    set(handles.text10,'String','natural');
    set(handles.text11,'String','very natural');
    
elseif clicked == 5  % overall impres
    
    set(handles.text1,'String','What is your overall impression of the music?');
    set(handles.text7,'String','very bad');
    set(handles.text8,'String','bad');
    set(handles.text9,'String','neither good nor bad');
    set(handles.text10,'String','good');
    set(handles.text11,'String','very good');
    
else  % continue to next song
    
    turn_off_labels(handles);
    
end

    
function turn_off_labels(handles)
     
    % potentially clear axes image
    cla(handles.axesImage, 'reset');
    set(handles.axesImage,'YTick',NaN); 
    set(handles.axesImage,'XTick',NaN); 
    set(handles.axesImage,'XColor','white'); 
    set(handles.axesImage,'YColor','white');

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

    
function set_title(handles)
        
    set(handles.text1,'Visible','on');
    
    
% --- Executes on mouse press over figure background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global clicked;

pos=get(hObject,'CurrentPoint');

YLim = get(handles.axesImage, 'YLim');
YLim = YLim(2);
coordinates = get(handles.axesImage, 'CurrentPoint');

x = coordinates(1,1);

if x < 86
    x = 1;
elseif x < 203
    x = 2;
elseif x < 321
    x = 3;
elseif x < 438
    x = 4;
elseif x < 556
    x = 5;
elseif x < 673
    x = 6;
elseif x < 791
    x = 7;
elseif x < 909
    x = 8;
else
    x = 9;
end

if clicked == 0
    fprintf(handles.fileID, strcat(num2str(handles.count), ['\t' num2str(x)]));
    clicked = 1;
    turn_on_labels(handles);
elseif clicked == 1
    fprintf(handles.fileID, strcat('\t', num2str(x)));
    clicked = 2;
    turn_on_labels(handles);
elseif clicked == 2
    fprintf(handles.fileID, strcat('\t', num2str(x)));
    clicked = 3;
    turn_on_labels(handles);
elseif clicked == 3
    fprintf(handles.fileID, strcat('\t', num2str(x)));
    clicked = 4;
    turn_on_labels(handles);
elseif clicked == 4
    fprintf(handles.fileID, strcat('\t', num2str(x)));
    clicked = 5;
    turn_on_labels(handles);
elseif clicked == 5
    fprintf(handles.fileID, strcat('\t', num2str(x), '\r\n'));
    clicked = 6;
    turn_on_labels(handles);
end

guidata(hObject, handles);
