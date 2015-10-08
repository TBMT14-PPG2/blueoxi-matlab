clear
close all
load('0104_8min.mat')

y=signal.pleth.y; %samples
Fs=param.samplingrate.pleth;
ref=reference.hr.pleth.x; % the refernace signal
N=length(y); % sample length
T = 1/Fs; %period
t = (0:N-1)*T; %seconds

% Calculate the first difference of the filtered signal
y_d = y(1:N-1) - y(2:N);

% --- Peak detector ---
% - Define variables used for the peak detector -
% Variable to save threshold values
crawler = zeros(length(y_d),1);

peak = 0;
peak_time = 0;
ptp = 0;
ptp_values = 1;
ptp_time = 0;
ptp_i = 1;
% Decay rate (in the beginning it is a constant so there would be something to start with)
decay = 0.01;
delay = 0;
% Variables for R wave detection
rwave_peaks = 0;
rwave_time = 0;
rwave_value = 0;
% Variables for measurement of R-wave width
r_width = 0;
r_width_arr = 0;



% - Peak detector (crawler) -
for i = 2 : length(y_d)-9
    
    % - Check if current point in the signal is a R peak -
    % To detect a peak, the signal at a particular point should satisfy
    % three conditions:
    %   * The signal should change its direction from rising to falling.
    %     This is done by detecting the point where first difference
    %     changes sign from positive to negative.
    %   * Current threshold level should be lower than the signal value at
    %     this point.
    %   * Delay should be over 1/10th of Sampling freqancy (1 second).
    %     This is done not to detect multiple peaks in the close vicinity
    
    if ((y_d(i,1) < 0 && y_d(i-1,1) > 0) && (crawler(i-1,1) < y(i,1) && (delay > Fs/10))) | ...
            ((y(i,1) < y(i-1,1) && y(i,1) < y(i+10,1)) && (crawler(i-1,1) < y(i,1) && (delay > Fs/10)))
            
            crawler(i,1) = y(i,1); % Set threshold to peak value
            
            % - Calculate and save Peak to Peak (R-R interval) -
            ptp = t(i) - peak_time;
            peak_time = t(i);
            ptp_values = [ptp_values; ptp];
            ptp_time = [ptp_time; t(i)];
            ptp_i = [ptp_i; i];
            peak = y(i,1);
            delay = 0;         % - Reset delay time -
            
    else  % - If a peak is not detected then decrease the threshold -
        decay = peak/100; % Calculate decay depending on the amplitude of the last detected peak
        if decay < 0.01
            decay=0.01;
        end
        crawler(i,1) = crawler(i-1,1) - decay; % Decrease the threshold by the decay rate and save it
        delay = delay + 1; % - Increment delay -
    end
end

plot(t(1:N-1), y(1:N-1), 'b');
hold on
plot(t(1:N-1), crawler, 'r');

L=length(ptp_time);
%calculate pulse in real time
for i=1:(L-1)
    pulse_real_time(i)=60/(ptp_time(i+1)-ptp_time(i));
end

l_ref=length(ref);
for i=1:(l_ref-1)
    pulse_real_ref(i)=60/(ref(i+1)-ref(i));
end

pulse=mean(pulse_real_time(3:end))
pulse_ref=mean(pulse_real_ref(3:end))

figure(2)
plot(ptp_time(1:L-1),pulse_real_time, 'b',ref(1:l_ref-1), pulse_real_ref, 'r')


