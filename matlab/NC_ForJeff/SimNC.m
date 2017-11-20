function out=SimNC(soundin,subject,trial)

%Right now sound is assumed to be single channel, this can be modified to
%support stereo if needed

%Set these parameters for later use in the nc_gain
pratiofun = 'none';         % 'none','2ndroot','3rdroot','4throot','log10','log','log2';
pratiowin = 'ones';         % 'bh','ones'

%Let sound be a vector derived externally

%Let subject be a .mat file containing patient parameters.  Identify the
%patient by a string.  

%Let trial be a .mat file containing training/simulation parameters
model2009_override = 0;
if ispc
load(['setupsInqueue\' trial]);
else
load(['setupsInqueue/' trial]);
end


%Program Flow: load patient left
%              simulate left and get results (nc_gain)
%              load patient right
%              simulate right and get results (nc_gain)
%We only need to simulate the hearing aid's operation.  We don't care about
%simulating the neural response

%Compose the file name for both left and right hearing parameter files
if ispc
    loadstringLeft=(['results\' subject '_left_' trial 'results']);
    loadstringRight=(['results\' subject '_right_' trial 'results']);
else
    loadstringLeft(['results/' subject '_left_' trial 'results']);
    loadstringRight(['results/' subject '_right_' trial 'results']);
end

%Get the patient's parameters for the Left ear
[hearLeft,VijLeft,UabLeft,EQALLeft,VolLeft]=GetHearingParameters(loadstringLeft);
EQLeft=EQALLeft.lft;
audio_in = preamp(soundin);
[yLeft,VijLeft] = nc_gain(audio_in,samp.Fs,samp.Nfft,EQLeft,UabLeft,VijLeft,gain.DPABFIdx,gain.DPAfreqs,pratiofun,pratiowin,gain.EQBFIdx,gain.EQfreqs,train.EQ,train.CE,train.DPA,train.findORIGNC,gain.smthTau,CE.min_dB,DPA.min_dB,DPA.interp,dsply.gain,VolLeft);
yLeft = postamp(yLeft);

%Right ear parameters
[hearRight,VijRight,UabRight,EQALRight,VolRight]=GetHearingParameters(loadstringRight);
EQRight=EQALRight.rgt;
audio_in = preamp(soundin);
[yRight,VijRight] = nc_gain(audio_in,samp.Fs,samp.Nfft,EQRight,UabRight,VijRight,gain.DPABFIdx,gain.DPAfreqs,pratiofun,pratiowin,gain.EQBFIdx,gain.EQfreqs,train.EQ,train.CE,train.DPA,train.findORIGNC,gain.smthTau,CE.min_dB,DPA.min_dB,DPA.interp,dsply.gain,VolRight);
yRight = postamp(yRight);









