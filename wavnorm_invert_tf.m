function y = wavnorm_invert_tf(x, spl, tf, sr)

% Normalizes input waveform to have a fixed SPL, and inverts the transfer
% function by filtering the signal in the frequency domain. 
% 
% Created by Sam Norman-Haignere on 6/29/2015

% invert transfer function
x_filt = specfilt(x, sr, tf.f, -tf.px + mean(tf.px));

% normalize
px = fftplot2(x_filt,sr,'tf',tf,'noplot');
gain = spl - 10*log10(sum(px));
y = 10^(gain/20) * x_filt;

if any(abs(y)>1)
    error('Error: waveform has values exceeding the allowable range (-1 to 1).');
end