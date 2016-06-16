function [spl,f] = sone2spl(sones, varargin)

% function [spl f] = sone2spl(sones, varargin)
% 
% Returns a spl vs. frequency contour corresponding to a particular sone level.
% 
% Interpolates sone vs. level contour for a single freuqency to get level
% vs. frequency contour for a particular sone level.
% Based on Moore's "loud2006a" software, see Glasberg & Moore, 2006.
% 
% 2015-06-28: Added file: tones-freqs-20-18000-levels-n20-120.mat.
% 
% -- Example: Equal loudness contours --
% 
% [spl, f] = sone2spl(1:7,'plot');

% load data file
p = load('tones-freqs-20-18000-levels-n20-120.mat');

% set NaN values to zero
p.sones(isnan(p.sones)) = 0;

% interpolate to estimate sone contour
sone_contour = nan(length(p.f),length(sones)); 
for j = 1:length(sones)
    for i = 1:length(p.f)
        [~,xi] = unique(p.sones(:,i));
        sone_contour(i,j) = myinterp1( p.sones(xi,i), p.spl(xi), sones(j), 'pchip' );
    end
end

if optInputs(varargin, 'plot')
    figure;
    semilogx(p.f,sone_contour,'k','LineWidth',2);
    ylim([0 120]);
    ylabel('SPL (dB)');
    xlabel('Frequency (Hz)');
end

if optInputs(varargin, 'freq')
    freq = varargin{optInputs(varargin, 'freq')+1};
    spl = nan(length(freq), length(sones));
    for j = 1:length(sones)
        spl(:,j) = myinterp1(log2(p.f),sone_contour(:,j),log2(freq),'pchip');
    end
    if optInputs(varargin, 'plot');
        hold on;
        plot(freq,spl,'ro','LineWidth',2);
        hold off;
    end
else
    f = p.f;
    spl = sone_contour;
end

