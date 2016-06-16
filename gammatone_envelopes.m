function [subband_envs, cfs, t] = gammatone_envelopes(wav,sr,plot_envelopes,varargin)

% function [subband_envs, cfs, t] = gammatone_envelopes(wav,sr,plot_envelopes,varargin)
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
% fmin: cf of the lowest-frequency filter (default: 50)
% 
% nfilts: number of filters between fmin and the nyquist; has no affect on bandwidth (default: 256)
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
nfilts = 128; % number of ERB-spaced samples
if optInputs(varargin, 'nfilts')
    nfilts = varargin{optInputs(varargin, 'nfilts')+1};
end
fmin = 100; % lowest gammatone frequency
if optInputs(varargin, 'fmin')
    fmin = varargin{optInputs(varargin, 'fmin')+1};
end

% calculate the envelopes
[fcoefs, F] = MakeERBFilters(sr,nfilts,fmin);
cfs = flipud(F);
subbands = ERBFilterBank(wav,flipud(fcoefs))';
subband_envs = abs(hilbert(subbands));

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

% time samples
t = (0:size(subband_envs,1)-1)'/env_sr;

% truncate, only relevant if power-law compression used
if strcmp(compression_type,'power')
    subband_envs(subband_envs<0)=0;
end

if optInputs(varargin, 'logf')
    
    log_cfs = logspace(log10(cfs(1)), log10(cfs(end)),length(cfs));
    
    subband_envs_log_cfs = nan(size(subband_envs));
    for i = 1:size(subband_envs,1)
        subband_envs_log_cfs(i,:) = interp1(log2(cfs), subband_envs(i,:)', log2(log_cfs));
    end
    
    cfs = log_cfs';
    subband_envs = subband_envs_log_cfs;
end

% plot
if plot_envelopes
    
    %     figure;
    imagesc(flipud(subband_envs'));
    set(gca,'FontName','Helvetica','FontSize',16);
    
    % frequency axis
    fticks = round( myinterp1(flipud(cfs), (1:length(cfs))', [200 400 800 1600 3200 6400]'));
    set(gca, 'YTick', flipud(fticks), 'YTickLabel', flipud([200 400 800 1600 3200 6400]'));
    ylabel('Frequency (Hz)');
    
    % time axis
    set(gca,'XTick',env_sr:env_sr:length(t));
    set(gca,'XTickLabel',round(t(env_sr:env_sr:length(t))));
    xlabel('Time (sec)');
end