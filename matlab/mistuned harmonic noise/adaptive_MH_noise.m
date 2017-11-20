function varargout = adaptive_MH_noise(varargin)
% ADAPTIVE_MH_NOISE M-file for adaptive_MH_noise.fig
%      ADAPTIVE_MH_NOISE, by itself, creates a new ADAPTIVE_MH_NOISE or raises the existing
%      singleton*.
%
%      H = ADAPTIVE_MH_NOISE returns the handle to a new ADAPTIVE_MH_NOISE or the handle to
%      the existing singleton*.
%
%      ADAPTIVE_MH_NOISE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADAPTIVE_MH_NOISE.M with the given input arguments.
%
%      ADAPTIVE_MH_NOISE('Property','Value',...) creates a new ADAPTIVE_MH_NOISE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before adaptive_MH_noise_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to adaptive_MH_noise_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help adaptive_MH_noise

% Last Modified by GUIDE v2.5 14-Mar-2012 16:15:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @adaptive_MH_noise_OpeningFcn, ...
                   'gui_OutputFcn',  @adaptive_MH_noise_OutputFcn, ...
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


% --- Executes just before adaptive_MH_noise is made visible.
function adaptive_MH_noise_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to adaptive_MH_noise (see VARARGIN)

% Choose default command line output for adaptive_MH_noise
handles.output = hObject;

if length(varargin) == 2

    [RP2,RV8,PA5x1,PA5x2] = load_circuits_mistuned();
    handles.RP2 = RP2;
    handles.RV8 = RV8;
    handles.PA5x1 = PA5x1;
    handles.PA5x2 = PA5x2;
    hide_activeX_controls(handles);
    
    handles.clicked = 0;
    handles.condition = varargin{1};
    handles.freq = varargin{2};
    
    % randomize randomization, move gui to correct spot
    rand('seed', sum(100*clock()));
    movegui(adaptive_MH_noise,'northwest');
    
end

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = adaptive_MH_noise_OutputFcn(hObject, eventdata, handles) 
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

handles.PA5x2.SetAtten(handles.PA5x2.GetAtten()-2);  % increase noise level

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.PA5x2.SetAtten(handles.PA5x2.GetAtten()+2);  % decrease noise level

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% STIMULUS PARAMETER SPECIFICATION AND STIMULUS CREATION
Fs = 44100;
j = sqrt(-1);
factor = 0.4;
curfactor = 1.3;  % start mistuning at obvious level
altered = ceil(rand(1)*3);
staircase = handles.condition;
freq = handles.freq;

phase = [2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi, 2*rand(1)*pi-pi]; 
modulus = [1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000];
real = sqrt(modulus.^2./([1,1,1,1,1,1,1,1,1,1]+tan(phase).^2));
imag = sqrt(modulus.^2 - real.^2);

c = zeros(Fs*2.5, 1);  % 2.5 seconds long
sigfft = zeros(44100,1);
    
% CREATE ORIG SIGNAL
    
for i=1:10
    sigfft(1+i*freq) = real(i) + j*imag(i);
    sigfft(44100+1-i*freq) = real(i) - j*imag(i);
end
    
sig = ifft(sigfft);
sig = sig(1:22050);  % take half of the signal
    
% apply linear 10ms rise/fall to the signal
for i=1:Fs*0.01
    sig(i) = sig(i)*(i/(Fs*0.01));
    sig(22051-i) = sig(22051-i)*(i/(Fs*0.01));
end
    
% CREATE MISTUNED SIGNAL
    
%up = floor(rand(1)*2);  % up == 0 => mistune down
                         % up == 1 => mistune up
up = 1;  % set up = 1, so harmonic is always mistuned up
         % this is what Claude Alain does in a published mistuned
         % harmonic in noise task, so it's probably safe to do this
    
if up == 0
    sigfft(freq*staircase+1) = 0;
    sigfft(44100-freq*staircase+1) = 0;
    sigfft(round(freq*staircase*(1/curfactor))+1) = real(staircase) + j*imag(staircase);
    sigfft(44100-round(freq*staircase*(1/curfactor))+1) = real(staircase) - j*imag(staircase);
else  % up == 1
    sigfft(freq*staircase+1) = 0;
    sigfft(44100-freq*staircase+1) = 0;
    sigfft(round(freq*staircase*curfactor)+1) = real(staircase) + j*imag(staircase);
    sigfft(44100-round(freq*staircase*curfactor)+1) = real(staircase) - j*imag(staircase);
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

c(1:end,2) = 0;  % make stereo signal

% ADD NOISE HERE FOR MISTUNED NOISE EXPERIMENT
% only 2 extra lines for mistuned harmonic noise experiment
nz = wgn(Fs*2.5,1,1);
c(1:end,2) = nz;

% apply linear 10ms rise/fall to the NOISE
for i=1:Fs*0.01
    c(i,2) = c(i,2)*(i/(Fs*0.01));
    c(2.5*Fs+1-i,2) = c(2.5*Fs+1-i,2)*(i/(Fs*0.01));
end

% eliminate click by making stimulus 50ms longer
c(end+1:end+Fs*0.05,1) = 0;  
c(end+1:end+Fs*0.05,2) = 0;
            
c = c';

Snd('Play',c, Fs);
set(handles.pushbutton1,'Enable','off');
set(handles.pushbutton2,'Enable','off');
set(handles.pushbutton4,'Enable','off');
Snd('Wait');
set(handles.pushbutton1,'Enable','on');
set(handles.pushbutton2,'Enable','on');
set(handles.pushbutton4,'Enable','on');

% Update handles structure
guidata(hObject, handles);
