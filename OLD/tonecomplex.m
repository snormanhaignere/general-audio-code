function [y gain] = tonecomplex(freqs,gain,dur,sr,varargin)

% function harm = tonecomplex(harmonics,gain,dur,sr,varargin)
% 
% returns a sound made up of a series of harmonics (sine waves)
% harmonics do not have to be integer multiples of a fundamental
% 
% arguments
% 
% harmonics: vector of harmonics (Hz)
% gain: vector that specifies relative level in dB for each harmonic
% dur: duration in seconds
% sr: sampling rate
% (optional) 'phase', phase: phase is vector specifying a phase offset in seconds, 'phase' is flag
% (optional) 'set-harm', harmnum: forces the a specific harmonic (specified in harmnum) 
% to have a specific rms-level (gain of other harmonics set relative to this)

%%

if any(freqs>sr/2)
    error('Frequencies above nyquist');
end

if length(gain) == 1;
    gain = gain*ones(1,length(freqs));
end

% phase of components
phase = zeros(size(freqs));
if optInputs(varargin,'phase')
    phase = varargin{optInputs(varargin,'phase')+1};
end

if optInputs(varargin,'spl')
    spl = varargin{optInputs(varargin,'spl')+1};
    gain = spl + gain - 10*log10(sum(10.^(gain/10)));
end

% inverts system response
if optInputs(varargin,'tf')
    tf = varargin{optInputs(varargin,'tf')+1};  
    gain = gain - myinterp1(log2(tf.f), tf.px, log2(freqs), 'cubic');
end

n = round(dur*sr);
t = linspace(0,dur,n+1)';
t = t(1:end-1);
y = zeros(n,1);
for i = 1:length(freqs)
    y = y + 10^(gain(i)/20) * sqrt(2) * sin(2*pi*freqs(i)*t + phase(i));
end