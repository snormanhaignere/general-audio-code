function y = wavnorm(x, spl, tf, sr)

% Normalizes input waveform to have a fixed SPL.
% Requires an input transfer function specifying 
% the gain at different frequencies.
% 
% June 28, 2015 - Modified by Sam Norman-Haignere to check that the
% normalized waveform does not have values outside the allowable range.

px = fftplot2(x,sr,'tf',tf,'noplot');
gain = spl - 10*log10(sum(px));
y = 10^(gain/20) * x;

if any(abs(y)>1)
    fprintf('WARNING: waveform has values exceeding the allowable range (-1 to 1).\n\n');
    %     error('Error: waveform has values exceeding the allowable range (-1 to 1).');
end