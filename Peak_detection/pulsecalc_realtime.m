clear all
close all
clc

[Y, Fs]=audioread('palm.wav');
X=Y(:,1);
y=Filter_PPG(X);

% load('C:\Users\Patrik\Documents\MATLAB\data\0128_8min.mat')
% y=signal.pleth.y;
% Fs=param.samplingrate.pleth;

ptp_time=0;
five_pulses=60*ones(1,5);
avg_pulse=60;

k=Fs;
N=length(y);
T = 1/Fs;
t = (0:N-1)*T;
peaktime=1;
peaks=0;
for i=1:(length(y)-k*2)
        
        if i<k+1
            peakmatch(i)=max(y(1:i+k));
        else
            peakmatch(i)=max(y(i-k:i+k));
        end
        
        if ( peakmatch(i)==y(i) && t(i)>t(peaktime(end))+30/avg_pulse(end) )
           peaktime=[peaktime i];
           peaks=[peaks y(i)];
           ptp_time = [ptp_time; t(i)];
        
            if length(ptp_time)>1   
                five_pulses=[five_pulses(2:5) 60/(ptp_time(end)-ptp_time(end-1))];
                avg_pulse=[avg_pulse mean(five_pulses)];
                k=round((60/avg_pulse(end))*Fs/2);
            end
        end
end



figure(444)
subplot(2,1,1)
plot(y)
hold on
plot(peakmatch,'r'); title('filtered signal with peaks identified');
scatter(peaktime(2:end),peaks(2:end),'k','o')
hold off
subplot(2,1,2)
hold
plot(avg_pulse); title('pulse')
if Fs~=1000
    plot(reference.hr.pleth.y,'r')
    legend('average pulse', 'reference pulse')
end
