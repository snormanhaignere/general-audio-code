function [px, f] = erbplot2(wav,sr,plot_excitation,varargin)

% [px, f] = erbplot2(wav,sr,plot_excitation,varargin)
% 
% Returns an estimate of the average cochlear excitation pattern to an input waveform.
% 
% -- Required Inputs --
% 
% wav: input waveform
% 
% sr: sampling rate in Hz plot_excitation: whether or not to plot the excitation pattern computed
% 
% -- Outputs --
% 
% px: average excitation power in unreference dB units
% 
% f: center frequency of each channel
% 
% -- Optional Inputs --
% 
% fmin: cf of the lowest-frequency filter (default: 50)
% 
% nfilts: number of filters between fmin and the nyquist; has no affect on bandwidth (default: 256)
% 
% onset_buffer: to avoid onset affects, can optionally exclude some portion of the filter's response
% at the beginning of the response, onset_buffer specifies the amount of the response to exclude in
% seconds (default: 0)
% 
% tf (typically not relevant): transforms the excitation pattern using an arbitrary transfer
% function. The frequencies (tf.f) and output power (tf.px) of the spectrum are specified as fields
% of the input structure 'tf'.
% 
% middle_ear_attenuation: whether or not to apply middle ear attenutation (default: false)
% 
% The optional inputs fmin, nfilts, onset_buffer, and tf are specified in the form: ... ,
% 'variable_name', variable_value, ...
% 
% middle_ear_attenuation is just specified as an extra flag, e.g.  ..., 'middle_ear_attenuation', ...
% 
% -- Example: 1 kHz pure tone --
% 
% sr = 20e3; 
% t = (1:sr)/sr; 
% wav = sqrt(2)*sin(2*pi*t*1000); 
% plot_excitation = true; 
% erbplot2(wav, sr, plot_excitation);
% 
% Last modified by Sam NH on 5/31/2015

% default parameters
nfilts = 256; % number of filters
fmin = 50; % cf for the lowest filter
onset_buffer = 0.1; % duration of filter responses to exclude at the onset 
middle_ear_attenuation = false;

% middle ear transfer function, based on Glasberg and Moore, 2006
middle_ear.f =  [20 25 32 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500];
middle_ear.px = -[40 32 25 21 18 16 15 13  11  9   8   7   6   5   4   3   3   3    5    7    8    10   7    7    7    10   12   10    15   ]+3;

% optional inputs
if optInputs(varargin, 'nfilts')
    nfilts = varargin{optInputs(varargin, 'nfilts')+1};
end
if optInputs(varargin, 'fmin')
    fmin = varargin{optInputs(varargin, 'fmin')+1};
end
if optInputs(varargin, 'onset_buffer')
    onset_buffer = varargin{optInputs(varargin, 'onset_buffer')+1};
end
if optInputs(varargin, 'middle_ear_attenuation')
    middle_ear_attenuation = varargin{optInputs(varargin, 'middle_ear_attenuation')+1};
end

% adds slaney filters
addpath(strrep(which('erbplot2.m'),'erbplot2.m','gammatonegram/'));

% filter responses
[fcoefs,F] = MakeERBFilters(sr, nfilts, fmin);
fcoefs = flipud(fcoefs);
f = flipud(F);
f = f(:);
XF = ERBFilterBank(wav,fcoefs);

% exclude onset responses
XF = XF(:,onset_buffer*sr+1:end);
% imagesc(10*log10(XF.^2));

% average power
px = nanmean(XF.^2,2);
px = px(:);

% apply middle transfer function
if middle_ear_attenuation
    gain = myinterp1(log2(middle_ear.f), middle_ear.px, log2(f(2:end)), 'pchip')';
    px(2:end) = px(2:end) .* 10.^(gain(:)/10);
end

% apply alternate transfer function
if optInputs(varargin,'tf');
    tf = varargin{optInputs(varargin, 'tf')+1};
    gain = myinterp1(log2(tf.f), tf.px, log2(f(2:end)), 'cubic')';
    px(2:end) = px(2:end) .* 10.^(gain(:)/10);
end

% plot
if plot_excitation
    figure;
    semilogx(f(2:end),10*log10(px(2:end)),'k','LineWidth',1);
    set(gca,'XTick',logspace(1,4,4),'FontName','Helvetica','FontSize',16);
    xlim([20 20000]);
    ylim(max(10*log10(px)) + [-70 10]);
    xlabel('Center Frequency (kHz)'); ylabel('Excitation Power (dB)');
end


