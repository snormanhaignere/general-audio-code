function sound_checkvol(x,sr)
% function sound_checkvol(x,sr)
% 
% Simple wrapper for the sound function
% which checks to make sure the overall 
% power of the waveform is not too high
% (rms(x) < 0.1). 

if rms(x(:)) > 0.1;
    error('Waveform RMS > 0.1');
end
sound(x,sr);