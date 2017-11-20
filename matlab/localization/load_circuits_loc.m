% --- Loads the rp2, rv8, and pa5s
function [RP2,RV8,PA5x1,PA5x2] = load_circuits_loc(lowhigh)

    % Connects to RP2, RV8, PA5s, loads and runs RV8 circuit
    % Checks whether the circuits were loaded properly
    path='C:\Users\user\Documents\Jeff\';
    %rp2circ='tdt circuits\RP2_Mixer.rco';
    rv8circ='speaker switching\PM2_EasySwitch.rco';

    CD='USB';
    Dnum=1;

    RP2=actxcontrol('RPco.x',[5 5 26 26]);
    %invoke(RP2,'ClearCOF'); %Clears all the Buffers and circuits on that RP2
    %invoke(RP2,'ConnectRP2',CD,Dnum); %connects RP2 via USB or Xbus given the proper device number
    %invoke(RP2,'LoadCOF',strcat(path,rp2circ)); % Loads circuit'
    %invoke(RP2,'Run'); %Starts Circuit'

    RV8=actxcontrol('RPco.x',[5 5 26 26]);
    invoke(RV8,'ClearCOF'); %Clears all the Buffers and circuits on that RV8
    invoke(RV8,'ConnectRV8',CD,Dnum); %connects RV8 via USB or Xbus given the proper device number
    invoke(RV8,'LoadCOF',strcat(path,rv8circ)); % Loads circuit'
    invoke(RV8,'Run'); %Starts Circuit'

    PA5x1=actxcontrol('PA5.x',[5 5 26 26]);
    invoke(PA5x1,'ConnectPA5',CD,Dnum); %connects PA5 via USB or Xbus given the proper device number

    PA5x2=actxcontrol('PA5.x',[5 5 26 26]);
    invoke(PA5x2,'ConnectPA5',CD,Dnum+1); %connects PA5 via USB or Xbus given the proper device number

    %Status=double(invoke(RP2,'GetStatus')); %converts value to bin'
    %if bitget(Status,1)==0  %checks for errors in starting circuit'
    %   er='Error connecting to RP2';
    %elseif bitget(Status,2)==0  %checks for connection'
    %   er='Error loading circuit';
    %elseif bitget(Status,3)==0
    %   er='error running circuit';
    %else  
    %   er='RP2 Circuit loaded and running';
    %end

    Status=double(invoke(RV8,'GetStatus'));%converts value to bin'
    if bitget(Status,1)==0  %checks for errors in starting circuit'
       er='Error connecting to RV8';
    elseif bitget(Status,2)==0  %checks for connection'
       er='Error loading circuit';
    elseif bitget(Status,3)==0
       er='error running circuit';
    else  
       er='RV8 Circuit loaded and running';
    end
    
    % activate the PM2
    er = RV8.SetTagVal('Speaker', 1);
    if er
    else
        error = 'Error setting RV8 Tag'  % print out error
    end
    RV8.SoftTrg (1);

    % set diff PA5 attenuation settings for phone, low-, and high-freq stim
    % with amp dial pointing at 5, max volume on comp
    if (lowhigh == 1)  % phone stim
        PA5x1.SetAtten(35);  % 65-70 dB SPL CF
        PA5x2.SetAtten(38);  % most around 67 dB
    elseif (lowhigh == 2)  % low freq stim
        PA5x1.SetAtten(20);  % 65-70 dB SPL CF
        PA5x2.SetAtten(23);  % most around 67 dB
    elseif (lowhigh == 3)  % high freq stim
        PA5x1.SetAtten(35);  % 65-70 dB SPL CF
        PA5x2.SetAtten(38);  % most around 67 dB
    else
        err = 'You must input one of 1, 2, or 3 as an argument to the function.'
    end
    
end