function segs = chunks_without_pauses(wav, segdur_sec, nseg, sr, varargin)

% Finds continuous segments of an audio waveform without too many pauses
%
% 2018-09-05: Last modified

% parameters
clear P;
P.win_sec = 0.1;
P.randseed = 1;
P.power_thresh = -30; % threshold relative to the max with which to determine silences
P.silence_thresh = 0.2; % max amount of silence allowed in a chunk
P.plot = true;
P.hcut = NaN; % cutoff of highpass filter to remove low-frequency noise (NaN indicates no filter)
P.randseed = 1;
P = parse_optInputs_keyvalue(varargin, P);

% ensure mono
assert(size(wav,2)==1);

% reset random seed
ResetRandStream2(P.randseed);

% window in samples
win_smp = P.win_sec*sr;

% number of hops
nwin = floor(length(wav)/win_smp);

% filter waveform
if ~isnan(P.hcut)
    [B,A] = butter(4,P.hcut/(sr/2),'high');
    wav_filt = filtfilt(B,A,wav);
else
    wav_filt = wav;
end

% caclulate the power in each window
pow = nan(1, nwin);
for i = 1:nwin
    xi = (1:win_smp) + (i-1)*win_smp;
    pow(i) = 10*log10(mean(wav_filt(xi).^2));
end
pow = pow - max(pow);

% segment duration in windows
segdur_win = round(segdur_sec/P.win_sec);

% determine the silence fraction for each segment
frac_silence = nan(nwin-segdur_win+1, 1);
for i = 1:nwin-segdur_win+1
    xi = (1:segdur_win)+(i-1);
    frac_silence(i) = mean(pow(xi) < P.power_thresh);
end

if P.plot
    figure;
    plot(frac_silence, 'LineWidth', 2);
    hold on;
    xL = xlim;
    plot(xL, P.silence_thresh * [1, 1], 'r--', 'LineWidth', 2);
end

% randomly choose segments that satisfy criteria
valid_segments = find(frac_silence < P.silence_thresh);
chosen_segments = nan(1, nseg);
for i = 1:nseg
    if isempty(valid_segments)
        warning('Not enough segments');
        nseg = i-1;
        break;
    end
    valid_segments = Shuffle(valid_segments);
    chosen_segments(i) = valid_segments(1);
    valid_segments = setdiff(valid_segments, chosen_segments(i) + (-(segdur_win-1):(segdur_win-1)));
end

% chop out the segments
segs = nan(round(sr*segdur_sec), nseg);
for i = 1:nseg
    xi = (1:round(sr*segdur_sec)) + (chosen_segments(i)-1)*win_smp;
    segs(:,i) = wav(xi);
end

function [Y,index] = Shuffle(X)
% [Y,index] = Shuffle(X)
%
% Randomly sorts X.
% If X is a vector, sorts all of X, so Y = X(index).
% If X is an m-by-n matrix, sorts each column of X, so
%	for j=1:n, Y(:,j)=X(index(:,j),j).
%
% Also see SORT, Sample, Randi, and RandSample.

% xx/xx/92  dhb  Wrote it.
% 10/25/93  dhb  Return index.
% 5/25/96   dgp  Made consistent with sort and "for i=Shuffle(1:10)"
% 6/29/96	  dgp  Edited comments above.
% 5/18/02   dhb  Modified code to do what comments say, for matrices.
% 6/2/02    dhb  Fixed bug introduced 5/18.

[null,index] = sort(rand(size(X)));
[n,m] = size(X);
Y = zeros(size(X));
if n == 1 || m == 1
	Y = X(index);
else
	for j = 1:m
		Y(:,j)  = X(index(:,j),j);
	end
end
 

