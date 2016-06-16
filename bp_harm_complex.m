function [wav, f, pf] = bp_harm_complex(F0, pb, filt_atten, dur, sr, varargin)

% [wav, f, pf] = bp_harm_complex(F0, pb, filt_atten, dur, sr, varargin)
% 
% Synthesizes a bandpass, harmonic complex.
% 
% -- Required Inputs --
% 
% F0: F0 of the harmonic complex
% 
% pb: the lower and upper cutoff of the passband in Hz, i.e. [lco_hz, uco_hz]
% 
% filt_atten: harmonics outside the passband are attenuated by filt_atten *
% num_octaves_from_passband, set filt_atten = inf to just include harmonics in the passband
% 
% dur: duration of the complex in seconds
% 
% sr: sampling rate
% 
% -- Outputs -- 
% 
% wav: waveform of the complex
% 
% f: harmonic frequencies in the complex
% 
% pf: power of each frequency
% 
% -- Optional Inputs Arguments --
% 
% pcomplex: normalize the overall level of the complex to have a specified value in unreferenced dB
% units (i.e. pcomplex = 10*log10(rms(wav))), default is just the summed power of the harmonics,
% which are initially set to each have unit power (0 dB, unreferenced) and are then attenuated
% according to their logarithmic distance from the passband
% 
% phaserel: the phase relation of the harmonics; options are sine phase ('sine', the default), cosine
% phase ('cos'), random phase ('rnd'), and various schroeder phase relations (e.g. 'schr-nharms',
% 'schr-1ERB') The schroeder phase relations minimize the peak factor of the waveform (in the case
% of 'schr-nharms') or the peak factor of the waveform after filtering into cochlear channels (in
% the case of 'schr-1ERB')
% 
% erbatten: optionally attenuate each harmonic in proportion to the ERB at each frequency
% 
% pcomplex and phaserel are specified in the form: ..., 'VARIABLE_NAME', VARIABLE_VALUE, ... 
% erbatten is just specified as an extra flag, e.g.  ..., 'erbatten', ...
% 
% -- Example complex with harmonics 10-20 of a 100 Hz F0 in the passband --
% F0 = 100;
% pb = [1000 2000];
% filt_atten = 75; % 75 dB/octave attenuation
% dur = 1;
% sr = 20000;
% [wav, f, pf] = bp_harm_complex(F0, pb, filt_atten, dur, sr, 'pcomplex', -30, 'phaserel', 'sine');
% fftplot2(wav,sr);
% sound_checkvol(wav,sr);
% 
% -- Illustration of schroeder phase --
% F0 = 100;
% pb = [1000 2000];
% filt_atten = inf; 
% dur = 1;
% sr = 20000;
% wav_sine = bp_harm_complex(F0, pb, filt_atten, dur, sr, 'pcomplex', -30, 'phaserel', 'sine');
% wav_schr = bp_harm_complex(F0, pb, filt_atten, dur, sr, 'pcomplex', -30, 'phaserel', 'schr-nharms');
% figure;
% subplot(1,2,1);
% plot(wav_sine(1:(1/F0)*sr*6));
% ylim([-0.2 0.2]);
% xlabel('Samples'); ylabel('Waveform Amplitude');
% title('Sine Phase');
% subplot(1,2,2);
% plot(wav_schr(1:(1/F0)*sr*6));
% ylim([-0.2 0.2]);
% xlabel('Samples'); ylabel('Waveform Amplitude')
% title('Schroeder Phase');

% phase relation to use
phaserel = 'sine';
if optInputs(varargin, 'phaserel')
    phaserel = varargin{optInputs(varargin, 'phaserel')+1};
end

% harmonics to filter
harms = 1:floor((sr/2)/F0);
pf = zeros(size(harms));

% erb attenuation
if optInputs(varargin, 'erbatten')
    x = find(F0*harms >= pb(1) & F0*harms <= pb(2));
    erb = 24.7*(4.37*F0*harms(x)/1000 + 1);
    pf(x) = pf(x) - 10*log10(erb) + 10*log10(erb(1));
    pf(1:x(1)) = pf(x(1));
    pf(x(end):end) = pf(x(end));
end

% attenuate harmonics outside the passband
if isinf(filt_atten)
    harms = harms( F0*harms >= pb(1) & F0*harms <= pb(2) );
    pf = zeros(size(harms));
else
    % low-frequency falloff
    x = F0*harms < pb(1);
    pf(x) = pf(x) + filt_atten * log2(F0*harms(x)/pb(1));
    
    % high-frequency falloff
    x = F0*harms > pb(2);
    pf(x) = pf(x) + filt_atten * log2(pb(2)./(F0*harms(x)));
end

% center frequency and erb
cf = geomean(pb);
erb = 24.7*(4.37*cf/1000 + 1);

% phase
switch phaserel
    case 'sine'
        harm_phases = zeros(size(harms));
    case 'cos'
        harm_phases = (pi/2)*ones(size(harms));
    case 'rnd'
        harm_phases = rand(size(harms))*2*pi;
    case 'schr-nharms'
        N = ((pb(2)-pb(1))/F0) + 1;
        x = 1:length(harms);
        harm_phases = -pi*x.*(x-1)/(N-1); % cycles through every N harmonics
    case 'schr-05ERB'
        N = 0.5*erb/F0 + 1;
        x = 1:length(harms);
        harm_phases = -pi*x.*(x-1)/(N-1); % cycles through every N harmonics
    case 'schr-1ERB'
        N = 1*erb/F0 + 1;
        x = 1:length(harms);
        harm_phases = -pi*x.*(x-1)/(N-1); % cycles through every N harmonics
    case 'schr-2ERB'
        N = 2*erb/F0 + 1;
        x = 1:length(harms);
        harm_phases = -pi*x.*(x-1)/(N-1); % cycles through every N harmonics
    case 'schr-4ERB'
        N = 4*erb/F0 + 1;
        x = 1:length(harms);
        harm_phases = -pi*x.*(x-1)/(N-1); % cycles through every N harmonics
    otherwise
        error('No valid phase relation');
end

% frequencies and power of harmonics in output spl
f = F0*harms;
[wav, pf] = tonecomplex2(f, pf, dur, sr, 'phases', harm_phases, varargin{:});