%% Open PsychPortAudio 'Device'

% sampling rate
sr = 44100;

% 2 channels for stereo
nchannels = 2; % two channels for steroe

% misc parameters
playbackmode = 1; % just play sounds, don't record or do anything else funny
latencyclass = 1; % controls how agressive PTB is in ensuring timing precicions

% close any existing channels
PsychPortAudio('Close'); 

% open new channel
pahandle = PsychPortAudio('Open',[],playbackmode,latencyclass,sr,nchannels);

%% Create a 1kHz tone

t = (1:sr)/sr;
tone = sin(t * 2*pi * 1000);

% ramp to prevent click due to rapid onset
tone = 0.05 * tone / sqrt(mean(tone(:).^2));
tone(1:sr*0.01) = tone(1:sr*0.01) .* (1:sr*0.01)/(sr*0.01);
tone(end:-1:end-sr*0.01+1) = tone(end:-1:end-sr*0.01+1) .* (1:sr*0.01)/(sr*0.01);

% RMS NORMALIZE TO PREVENT DEAFNESS ** VERY IMPORTANT **
tone = 0.01 * tone / sqrt(mean(tone(:).^2));

%% Play a 1kHz tone from the left ear

% add tone to left channel channel
stereo_signal = zeros(2, sr);
stereo_signal(1,:) = tone;

PsychPortAudio('FillBuffer',pahandle,stereo_signal);
PsychPortAudio('Start', pahandle);
WaitSecs(1.5);

%% Play a 1 kHz tone from the right ear

% add tone to right channel
stereo_signal = zeros(2, sr);
stereo_signal(2,:) = tone;

PsychPortAudio('FillBuffer',pahandle,stereo_signal);
PsychPortAudio('Start', pahandle);
WaitSecs(1.5);

%% Play a 1kHz tone from both ears

% add tone to left and right channel
stereo_signal = zeros(2, sr);
stereo_signal(1,:) = tone;
stereo_signal(2,:) = tone;

PsychPortAudio('FillBuffer',pahandle,stereo_signal);
PsychPortAudio('Start', pahandle);
WaitSecs(1.5);
