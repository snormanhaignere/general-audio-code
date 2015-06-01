function [subband_envs, cfs, t] = gammatone_envelopes(wav,sr,plot_envelopes,varargin)

% function [subband_envs, f, t, env_sr] = gammatone_envelopes(wav,sr,plot_envelopes,varargin)
% 
% Calculates subband envelopes using a bank of gammatone filters as implemented by Slaney (1998).
% Envelopes are computed using the hilbert transform, and (optionally) compressed using a power-law
% (default ^0.3), and downsampled (by default to 400 Hz).
% 
% -- Required Inputs --
% 
% wav: audio waveform
% 
% sr: sampling rate in Hz
% 
% plot_envelopes: whether or not to plot the envelopes
% 
% -- Outputs --
% 
% subband_envs: the compressed and downsampled envelopes
% 
% cfs: center frequencies of the gammatone filters
% 
% t: time-points corresponding to the sampled envelopes
% 
% -- Optional Inputs --
% 
% env_sr: The envelope sampling rate (default: 400 Hz)
% 
% compression_type: Whether to apply power-law ('power') and logarithmic ('log') compression.
% Default is to raise envelopes to the power of 0.3. Specify 'none' if no compression is desired.
% 
% compression_exponent: exponent with which to raise the envelopes

% add path to slaney filters
addpath(strrep(which('gammatone_envelopes.m'),'gammatone_envelopes.m','gammatonegram/'));

% optional inputs
env_sr = 400; % envelope sampling rate
if optInputs(varargin, 'env_sr')
    env_sr = varargin{optInputs(varargin, 'env_sr')+1};
end
compression_type = 'power'; % the type of compression to use
if optInputs(varargin, 'compression_type')
    compression_type = varargin{optInputs(varargin, 'compression_type')+1};
end
compression_exponent = 0.3; % power subband envelopes are raised to if power-law compression is used
if optInputs(varargin, 'compression_factor')
    compression_exponent = varargin{optInputs(varargin, 'compression_factor')+1};
end

% gammatone parameters
n_freqs = 128; % number of ERB-spaced samples
lowfreq = 100; % lowest gammatone frequency

% calculate the envelopes
[fcoefs, F] = MakeERBFilters(sr,n_freqs,lowfreq);
cfs = flipud(F);
subbands = ERBFilterBank(wav,flipud(fcoefs))';
subband_envs = abs(hilbert(subbands));
t = (1:size(subband_envs,1))'/env_sr;

% compression
switch compression_type
    case {'log'}
        subband_envs = 20*log10(subband_envs);
    case {'power'}
        subband_envs = subband_envs.^ compression_exponent;
    case {'none'}
    otherwise
        error('Error in gammatone_envelopes.m: compression_type must be ''power'', ''log'', or ''none''');
end
        
% downsample
subband_envs = resample(subband_envs, env_sr, sr);

% truncate, only relevant if power-law compression used
if strcmp(compression_type,'power')
    subband_envs(subband_envs<0)=0;
end

% plot
if plot_envelopes
    %     figure;
    fontweight = 'Demi';
    fontsize = 14;
    set(gca,'FontWeight',fontweight,'FontSize',fontsize);
    imagesc(flipud(subband_envs'),[0 0.5]);
    set(gcf, 'PaperPosition', [0 0 12 8]);
    set(gca,'YTick',fliplr(length(cfs):-10:1))
    set(gca,'YTickLabel',flipud(round(cfs(1:10:length(cfs)))),'FontWeight',fontweight,'FontSize',fontsize);
    ylabel('Frequency (Hz)');
    set(gca,'XTick',env_sr:env_sr:length(t));
    set(gca,'XTickLabel',round(t(env_sr:env_sr:length(t))),'FontWeight',fontweight,'FontSize',fontsize);
    xlabel('Time (sec)');
end