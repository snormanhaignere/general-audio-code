function y = ramp_hann(x,ramp_dur,sr)

% Apply hanning/raised-cosine window to the beginning and end of a signal
% 
% -- Inputs --
% 
% x: signal to be ramped
% 
% ramp_dur: duration of the ramp/window
% 
% sr: sampling rate of the signal
% 
% -- Example: Ramp a ones vector -- 
% 
% sr = 20e3;
% ramp_dur = 0.2;
% signal_dur = 1;
% x = ones(signal_dur*sr,1);
% y = ramp_hann(x, ramp_dur, sr);
% plot((0:sr*signal_dur-1)'/sr,[x,y]);
% xlabel('Time (s)'); ylabel('Waveform Amplitude');
% legend('Original', 'Ramped');

% number of channels
n_channels = size(x,2);

% create window
n_smp_win = ramp_dur*sr;
t = (0:n_smp_win-1)';
period = (n_smp_win-1)*2;
win = 0.5 * (1 - cos(2*pi*t/period));

y = x;
y(t+1,:) = x(t+1,:) .* repmat(win, 1, n_channels);
y(end-t,:) = x(end-t,:) .* repmat(win, 1, n_channels);

