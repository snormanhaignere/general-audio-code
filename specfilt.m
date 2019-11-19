function wav_filtered = specfilt(wav, sr, f, pf, varargin)

% wav_filtered = specfilt(wav, sr, f, pf, varargin)
% 
% Filters a waveform in the frequency domain, with the shaping spectrum given by vector f and pf
% (frequency and power, respectively) For frequencies outside the minimum and maximum frequencies
% specified in the vector f the spectrum level is attenuated by filt_atten dB per octave
% 
% Filtering is done by setting negative frequencies to zero,  filtering the positive frequencies and
% then discarding the imaginary component
% 
% -- Example: Notch filtering --
% 
% sr = 20e3;
% noise_unfiltered = gnoise_SNH(50, 10e3, 0, 75, 1, sr);
% f = [50 250 500 1000 2000 10e3]; 
% pf = [0 0 -50 -50 0 0];
% noise_filtered = specfilt(noise_unfiltered, sr, f, pf);
% [spec_unfiltered, freqs] = fftplot2(noise_unfiltered,sr);
% [spec_filtered, ~] = fftplot2(noise_filtered,sr);
% semilogx(freqs, 10*log10([spec_unfiltered, spec_filtered]));
% hold on;
% semilogx(f, pf,'k-o','LineWidth',2);
% ylim([-80 20]); xlim([50 10e3]);

% ensures everything is a row vector
if size(f,2) == 1;
    f = f';
end

if size(pf,2) == 1;
    pf = pf';
end

if size(wav,2) == 1;
    wav = wav';
end

% keyboard;
% maximum positive frequency in samples, the nyquist if nfft is even
% if nfft is 4, frequencies of the dft are 2*pi*[0, 1, 2, 3]/4
% in which case the third sample is the nyquist
% if nfft is 5, then the frequencies of the dft are 2*pi*[0, 1, 2, 3, 4]/5
% in this case, third sample is the maximum positive frequency but not the nyquist
nfft = length(wav);
max_pos_freq = ceil((nfft+1)/2); 

% 1: positive spectrum
spec_twosided = fft(wav);
spec_onesided = spec_twosided(1:max_pos_freq);

% 2: interpolate frequencies within the min and max bounds of the input frequencies
freqs = sr*(0:max_pos_freq-1)/nfft; % frequency vector
inds = freqs > min(f) & freqs < max(f); % frequencies within the range specified
pf_interp = interp1(log2(f),pf,log2(freqs(inds)),'pchip');

%%

spec_onesided_filtered = spec_onesided;
spec_onesided_filtered(inds) = spec_onesided(inds) .* 10.^(pf_interp/20);
% figure;
% plot(20*log10(abs([spec_onesided', spec_onesided_filtered'])))

%%
% 3: recreate the negative frequencies
if mod(nfft,2)==0 % if nyquist present
    spec_twosided_filtered = [spec_onesided_filtered, conj(spec_onesided_filtered(max_pos_freq-1:-1:2))];
else
    spec_twosided_filtered = [spec_onesided_filtered, conj(spec_onesided_filtered(max_pos_freq:-1:2))];
end

%4: convert back to audio domain
wav_filtered = ifft(spec_twosided_filtered);

