function [spl,f] = phon2spl(phons, varargin)

% function [spl,f] = phon2spl(phons, varargin)
% 
% Returns a spl vs. frequency contour corresponding to a particular phon level.
% Sounds are assumed to be presented binaurally using headphones calibrated at the eardrum. 
% 
% Interpolates phon vs. level contour for a single frequency to get level
% vs. frequency contour for a particular phon level.
% Based Moore's "loud2006a" software, see Glasberg & Moore, 2006.
% 
% 2015-06-28: Created by Sam Norman-Haignere 
% 
% -- Example: Equal loudness contours --
% 
% [spl, f] = phon2spl(0:10:100,'plot');
% 
% -- Example: Minumum audible pressure (MAP thresholds) --
% 
% phon_level_at_threshold = 2.5; % phon level for binaural, minimum audibile pressure
% [threshold, f] = phon2spl(phon_level_at_threshold,'plot');

% load data file
p = load('tones-freqs-20-18000-levels-n20-120.mat');

% interpolate to estimate sone contour
phon_contour = nan(length(p.f),length(phons)); 
for j = 1:length(phons)
    for i = 1:length(p.f)
        xi = ~isnan(p.phons(:,i));
        phon_contour(i,j) = myinterp1( p.phons(xi,i), p.spl(xi), phons(j), 'pchip' );
    end
end

if optInputs(varargin, 'plot')
    figure;
    semilogx(p.f,phon_contour,'k','LineWidth',2);
    ylim([0 120]);
    xlim([20 18e3]);
    ylabel('SPL (dB)');
    xlabel('Frequency (Hz)');
end

if optInputs(varargin, 'freq')
    freq = varargin{optInputs(varargin, 'freq')+1};
    spl = nan(length(freq), length(phons));
    for j = 1:length(phons)
        spl(:,j) = myinterp1(log2(p.f),phon_contour(:,j),log2(freq),'pchip');
    end
    if optInputs(varargin, 'plot');
        hold on;
        plot(freq,spl,'ro','LineWidth',2);
        hold off;
    end
else
    f = p.f;
    spl = phon_contour;
end

