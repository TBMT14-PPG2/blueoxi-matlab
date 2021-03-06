function [avg_pulse, y_r, BPM, S, S_avg] = func_pulsecalc(Y, Fs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% [Y, Fs]=audioread('wrist1.wav');
X_r=Y(:,1);
X_ir=Y(:,2);
[y_r, AC_r, DC_r]=Filter_PPG(X_r);
[y_ir, AC_ir, DC_ir]=Filter_PPG(X_ir);

ptp_time=0;
five_pulses=60*ones(1,5);
avg_pulse=60;

k=Fs;
N=length(y_r);
T = 1/Fs;
t = (0:N-1)*T;
peaktime=1;
peaks=0;
for i=1:(length(y_r)-k*2)
        
        if i<k+1
            peakmatch(i)=max(y_r(1:i+k));
        else
            peakmatch(i)=max(y_r(i-k:i+k));
        end
        
        if ( peakmatch(i)==y_r(i) && t(i)>t(peaktime(end))+30/avg_pulse(end) )
           peaktime=[peaktime i];
           peaks=[peaks y_r(i)];
           ptp_time = [ptp_time; t(i)];
        
            if length(ptp_time)>1   
                five_pulses=[five_pulses(2:5) 60/(ptp_time(end)-ptp_time(end-1))];
                avg_pulse=[avg_pulse mean(five_pulses)];
                k=round((60/avg_pulse(end))*Fs/2);
            end
        end
end

BPM = round(mean(avg_pulse));


% Saturation calculation
mya_r_Hb=1.819915; %660nm
mya_r_HbO2=1.802677e-1; %660nm
mya_ir_Hb = 3.91129e-1; %940nm
mya_ir_HbO2 = 6.847467e-1; %940nm
R = (AC_r./DC_r)./(AC_ir./DC_ir);
S = (mya_r_Hb - R.*mya_ir_Hb)./(R.*(mya_ir_HbO2 - mya_ir_Hb) - mya_r_HbO2 + mya_r_Hb)*100;

S_avg = round(mean(S));

% figure(444)
% subplot(2,1,1)
% plot(y)
% hold on
% plot(peakmatch,'r'); title('filtered signal with peaks identified');
% scatter(peaktime(2:end),peaks(2:end),'k','o')
% hold off
% subplot(2,1,2)
% hold
% plot(avg_pulse); title('pulse')
% if Fs~=1000
%     plot(reference.hr.pleth.y,'r')
%     legend('average pulse', 'reference pulse')
% end
end

