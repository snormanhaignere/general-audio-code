function [noise atten_all freqs] = gnoise_SNH(lco, hco, spec_level_init, filt_atten, dur, sr, varargin)
% function noise = gnoise_SNH(dur, lco, hco, filt_atten, sr, varargin)
% 
% generates bandpass gaussian noise in the spectral domain with low and high frequency
% cutoffs lco and hco. 
% 
% the spectral falloff on either side of the passband is filt_atten dB per octave
% filt_atten should be positive
% 
% if 'spec_atten' is specified as an optional argument the overall spectrum 
% is attenuated x dB per octave where x is the next argument after 'spec_atten'
% 
% if 'erbnorm' is specified as an optional argument, the power in each frequency bin
% is divided by size of the ERB at that frequency 

% optional octave, spectral attenuation
spec_atten = 0;
if optInputs(varargin, 'spec_atten');
    spec_atten = varargin{optInputs(varargin, 'spec_atten') + 1};
end

spec_atten_lco = lco;
if optInputs(varargin, 'spec_atten_lco');
    spec_atten_lco = varargin{optInputs(varargin, 'spec_atten_lco') + 1};
    if spec_atten_lco < lco || spec_atten_lco > hco
        error('Spectral attenuation cutoff should be within the passband');
    end
end

% frequency bin with power set to 1, should be in the pass band
% freq_unitpower = lco;
% if optInputs(varargin, 'setfreq2unitpower');
%     freq_unitpower = varargin{optInputs(varargin, 'setfreq2unitpower') + 1};
% end

if filt_atten < 0;
    error('Filter attenuation should be positive.');
end

fftpts = round(dur * sr);

binfactor = fftpts / sr;
lpbin = round(lco*binfactor) + 1;
hpbin = round(hco*binfactor) + 1;
attenbin = round(spec_atten_lco*binfactor) + 1;
nyq = ceil((fftpts+1)/2); % maximum positive frequency, nyquist if fftpts is even
freqs = (0:nyq-1)/binfactor;
isnyq = mod(fftpts,2)==0;

% unitpowbin = round(freq_unitpower*binfactor) + 1;

% % erb normalize
% if optInputs(varargin, 'erbnorm')
%     fspec2 = fspec1;
%     freqs = sr*linspace(0,nyq,nyq)/fftpts; 
%     erb = 24.7*(4.37*freqs/1000 + 1);
%     fspec2(1:nyq) = sqrt(1./erb) .* fspec1(1:nyq);
% else
%     fspec2 = fspec1;
% end

% attenuation applied to power spectrum in dB
atten_all = spec_level_init * ones(1,nyq);

if optInputs(varargin, 'ten')

    K = [0.0500   13.5000
        0.0630   10.0000
        0.0800    7.2000
        0.1000    4.9000
        0.1250    3.1000
        0.1600    1.6000
        0.2000    0.4000
        0.2500   -0.4000
        0.3150   -1.2000
        0.4000   -1.8500
        0.5000   -2.4000
        0.6300   -2.7000
        0.7500   -2.8500
        0.8000   -2.9000
        1.0000   -3.0000
        1.1000   -3.0000
        2.0000   -3.0000
        4.0000   -3.0000
        8.0000   -3.0000
        10.0000   -3.0000
        15.0000   -3.0000];
    
    K_interp = myinterp1(log2(K(:,1)*1000),K(:,2),log2(freqs(lpbin:hpbin)),'cubic');
    erb = 24.7*(4.37*freqs(lpbin:hpbin)/1000 + 1);
    atten_all(lpbin:hpbin) = atten_all(lpbin:hpbin) - 10*log10(erb) - K_interp; % assumes signal is at 0 dB

end

% octave attenuation of spectrum
atten_all(attenbin:hpbin) = atten_all(attenbin:hpbin) + spec_atten*log2(attenbin./(attenbin:hpbin));

% additional spectral filtering
if optInputs(varargin, 'specfilt')
    sf = varargin{optInputs(varargin,'specfilt')+1};
    atten_all(lpbin:hpbin) = atten_all(lpbin:hpbin) + myinterp1(log2(sf.f), sf.px, log2(freqs(lpbin:hpbin)), 'cubic');
end

% fix power outside passband to the border of passband
atten_all(1:lpbin-1) = atten_all(lpbin);
atten_all(hpbin+1:nyq) = atten_all(hpbin);

% bandpass filter with octave attenuation
if filt_atten > 500;
    atten_all( [1:lpbin-1, hpbin+1:nyq] ) = -inf;
else    
    % low frequency border
    atten_all(1:lpbin-1) = atten_all(1:lpbin-1) + filt_atten*log2((1:lpbin-1)/lpbin);
    
    % high frequency border
    atten_all(hpbin+1:nyq) = atten_all(hpbin+1:nyq) + filt_atten*log2(hpbin./(hpbin+1:nyq));
end

% spl normalization
if optInputs(varargin,'spl')
    spl = varargin{optInputs(varargin,'spl')+1};
    atten_all = atten_all + spl - 10*log10(sum(10.^(atten_all/10))/(fftpts/sr));
end
    
% inverts system response
if optInputs(varargin,'tf')
    tf = varargin{optInputs(varargin,'tf')+1};
    atten_all(2:end) = atten_all(2:end) - myinterp1(log2(tf.f), tf.px, log2(freqs(2:end)), 'cubic');
end

% gaussian noise with 0.5 power/Hz, or 1 power/Hz when collapsed across positive and negative frequencies
% (converted to appropriate power per bin value at end of script)
fspec_pos = (1/sqrt(2))*(1/sqrt(2))*(randn(1,nyq) + randn(1,nyq)*1i); 

% set DC to zero
fspec_pos(1) = 0;

% set nyquist to zero if present
if isnyq
    fspec_pos(nyq) = 0;
end

% apply attenutation spectrum
fspec_pos = fspec_pos .* 10.^( atten_all / 20 );

% complex conjugate negative spectrum
if isnyq
    fspec = [fspec_pos, conj(fspec_pos(nyq-1:-1:2))];
else
    fspec = [fspec_pos, conj(fspec_pos(nyq:-1:2))];
end

% % spl normalization
% if optInputs(varargin,'spl')
%     spl = varargin{optInputs(varargin,'spl')+1};
%     fspec = 10^(spl/20) .* fspec / sqrt(sum(abs(fspec).^2));
% end

% convert to time domain
noise = ifft(fspec * fftpts * sqrt(sr/fftpts));