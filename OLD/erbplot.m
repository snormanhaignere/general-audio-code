function [px, f] = erbplot(wav,sr,varargin)

addpath(strrep(which('erbplot.m'),'erbplot.m','gammatonegram/'));

% gammatone parameters
twin = 0.025; % default
thop = 0.010; % default
fbins = 512; % default
fmin = 20; % default

if optInputs(varargin,'twin')
    twin = varargin{optInputs(varargin,'twin')+1};
end

if optInputs(varargin,'thop')
    thop = varargin{optInputs(varargin,'thop')+1};
end

fontsize = 12;
fontweight = 'Demi';

[amp,f] = gammatonegram(wav,sr,twin,thop,fbins,fmin,sr/2,0);
px = nanmean(amp.^2,2);
px = px(:);
f = f(:);

if optInputs(varargin,'tf');
    tf = varargin{optInputs(varargin, 'tf')+1};
    gain = myinterp1(log2(tf.f), tf.px, log2(f(2:end)), 'cubic')';
    try
        px(2:end) = px(2:end) .* 10.^(gain(:)/10);
    catch
        keyboard
    end
end

% x = 21.4*log10(4.37*freq(1:2)/1000+1);
% erb_step = x(2)-x(1);
% pow_db = 20*log10(amp);
% pow_db_mean = nanmean(pow_db,2);

% pow_db_mean(pow_db_mean<-80) = -80;

if optInputs(varargin,'noplot')
    return;
end

semilogx(f(2:end),10*log10(px(2:end)),'k','LineWidth',1);
set(gca,'XTick',logspace(1,4,4),'FontWeight',fontweight,'FontSize',fontsize);
xlim([20 20000]);
ylim(max(10*log10(px)) + [-70 10]);

% xlim([10 20000]);%sr/2]);
% ylim([-70 -20]);
% xlabel('Frequency'); ylabel('dB');
%
% if optInputs(varargin,'title')
%     title(varargin{optInputs(varargin,'title')+1});
% end
% hold off;
