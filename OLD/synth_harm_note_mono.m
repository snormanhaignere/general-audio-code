function [note, f, pf] = synth_harm_note_mono(F0, pb, phaserel, dur, sr, spl, tf, filt_atten, varargin)

% function [note, f, pf] = synth_harm_note_mono(f0, pb, phaserel, dur, sr, spl, tf, filt_atten, varargin)
% 
% Synthesizes a single bandpass, harmonic complex.
% 
% -- Required Inputs --
% 
% F0: F0 of the harmonic complex
% pb: passband of the harmonic complex
% phaserel: phase relation of the harmonics (sine, cosine, random, or various schroeder phase relations)
% 

% harmonics to filter
harms = 1:floor(min(20000,sr)/F0);
gain = zeros(size(harms));

% erb attenuation
if optInputs(varargin, 'erbatten')
    x = find(F0*harms >= pb(1) & F0*harms <= pb(2));
    erb = 24.7*(4.37*F0*harms(x)/1000 + 1);
    gain(x) = gain(x) - 10*log10(erb) + 10*log10(erb(1));
    gain(1:x(1)) = gain(x(1));
    gain(x(end):end) = gain(x(end));
end

if isinf(filt_atten)
    harms = harms( F0*harms >= pb(1) & F0*harms <= pb(2) );
    gain = zeros(size(harms));
else
    % low-frequency falloff
    x = F0*harms < pb(1);
    gain(x) = gain(x) + filt_atten * log2(F0*harms(x)/pb(1));
    
    % high-frequency falloff
    x = F0*harms > pb(2);
    gain(x) = gain(x) + filt_atten * log2(pb(2)./(F0*harms(x)));
end

% center frequency and erb
cf = geomean(pb);
erb = 24.7*(4.37*cf/1000 + 1);

% phase
switch phaserel
    case 'sine'
        harmphases = zeros(size(harms));
    case 'cos'
        harmphases = (pi/2)*ones(size(harms));
    case 'rnd'
        harmphases = rand(size(harms))*2*pi;
    case 'schr-nharms'
        N = ((pb(2)-pb(1))/F0) + 1;
        x = 1:length(harms);
        harmphases = -pi*x.*(x-1)/(N-1); % cycles through every N harmonics
    case 'schr-05ERB'
        N = 0.5*erb/F0 + 1;
        x = 1:length(harms);
        harmphases = -pi*x.*(x-1)/(N-1); % cycles through every N harmonics
    case 'schr-1ERB'
        N = 1*erb/F0 + 1;
        x = 1:length(harms);
        harmphases = -pi*x.*(x-1)/(N-1); % cycles through every N harmonics
    case 'schr-2ERB'
        N = 2*erb/F0 + 1;
        x = 1:length(harms);
        harmphases = -pi*x.*(x-1)/(N-1); % cycles through every N harmonics
    case 'schr-4ERB'
        N = 4*erb/F0 + 1;
        x = 1:length(harms);
        harmphases = -pi*x.*(x-1)/(N-1); % cycles through every N harmonics
    otherwise
        error('No valid phase relation');
end

% frequencies and power of harmonics in output spl
f = F0*harms;
[~,pf] = tonecomplex(F0 * harms, gain, dur, sr, 'spl', spl);

% synthesize note
if optInputs(varargin, 'nonote')
    note = [];
else
    note = tonecomplex(f, gain, dur, sr, 'spl', spl, 'tf', tf, 'phase', harmphases);
end