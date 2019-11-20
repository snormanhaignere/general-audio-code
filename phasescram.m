function X_phasescram = phasescram(X)

% Phase scrambles the columns of signal matrix X
% 
% 2019-11-19: Created, Sam NH

% -- Example showing preservation of magnitude spectra -- 
% 
% X = randn(100,1);
% X_phasescram = phasescram(X);
% figure;
% subplot(1,2,1);
% fftplot2(X,1);
% subplot(1,2,2);
% fftplot2(X_phasescram,1);

% dimensions and unwrap
dims = size(X);
X = reshape(X, dims(1), prod(dims(2:end)));

% fourier transform of signal
FX = fft(X);

% split into dc, positive, nyquist, negative samples
N = size(X,1);
max_pos_freq_excluding_nyq = ceil(N/2);
if mod(N,2)==0
    nyq = ceil(N/2)+1;
else
    nyq = [];
end
FX_dc = FX(1,:);
FX_pos = FX(2:max_pos_freq_excluding_nyq,:);
FS_nyq = FX(nyq,:);

% phase scramble positive
FX_pos_amp = abs(FX_pos);
FX_pos_phase = FX_pos ./ FX_pos_amp;
FX_pos_scram = FX_pos_amp .* FX_pos_phase(randperm(size(FX_pos_phase,1)),:);

% reconstruct
FX_phasescram = [FX_dc; FX_pos_scram; FS_nyq; flipud(conj(FX_pos_scram))];

% back to signal domain
X_phasescram = ifft(FX_phasescram);

% reshape back
X_phasescram = reshape(X_phasescram, dims);
