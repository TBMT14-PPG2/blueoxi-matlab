clear


[Y, Fs]=audioread('ppg1.wav');
X=Y(:,1);

y=Filter_PPG(X);


% [b,a] = butter(2,[0.5 20]/(Fs/2), 'bandpass');
% y = filtfilt(b,a,X);
% [b,a] = butter(2,0.5, 'low');
% y1 = filter(b,a,y);

N=length(y);
T = 1/Fs;
t = (0:N-1)*T;

% - Calculate the first difference of the filtered ECG signal -
y_d = y(1:N-1) - y(2:N);

% --- Peak detector ---
% - Define variables used for the peak detector -
% Variable to save threshold values
crawler = zeros(length(y_d),1);

peak = 0;
ptp_time = 0;
% Decay rate (in the beginning it is a constant so there would be something to start with)
decay = 0.0001;
% Variable for delay
delay = 0;


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
    
    %if (y_d(i,1) > 0 && y_d(i-1,1) < 0) && (crawler(i-1,1) < y(i,1) && (delay > Fs/10))
    %doesn't work since some peaks are flat
    
    % if ((y_d(i,1) > 0 && y_d(i-1,1) < 0) && (crawler(i-1,1) < y(i,1) && (delay > Fs/10))) | ...
    %        ((y_d(i,1) == 0 && y_d(i-1,1) < 0 && y_d(i+7,1) > 0 ) && (crawler(i-1,1) < y(i,1) && (delay > Fs/10)))
    
    if (((y_d(i) > 0 && y_d(i-1) < 0) && (crawler(i-1) < y(i) && (delay > Fs))) || ...
            ((y(i) > y(i-1) && y(i) > y(i+10)) && (crawler(i-1) < y(i) && (delay > Fs))))
        
        
        %   if ((y_d(i,1) > 0 && y_d(i-1,1) < 0) | (y_d(i,1) == 0 && y_d(i-1,1)))  && ...
        %          ((y(i,1) > y(i+7)) && (y(i,1) > y(i+4)) && (y(i,1) > y(i+5)) && (y(i,1) > y(i+6)))
        
        %pröva med en ännu mer utförlig if sats
        
        
        
      %  if (((y_d(i) > 0 && y_d(i-1) < 0) | (y_d(i) == 0 && y_d(i-1))) && ...
       %         ((y(i) >= y(i+1) && y(i) >= y(i+2))))
            
            % Set threshold to peak value
            crawler(i) = y(i);
            
            % - Calculate and save Peak to Peak (R-R interval) -
            ptp_time = [ptp_time; t(i)];
            peak = y(i);
            
            % - Reset delay time -
            delay = 0;
            
            
            
            
       % end
        
        
        
        
        
        % - If a peak is not detected then decrease the threshold -
    else
        % Calculate decay depending on the amplitude of the last detected
        % peak
        decay = peak/100000;
        
        if decay < 0.000001
            decay=0.000001;
        end
        
        
        % Decrease the threshold by the decay rate and save it
        crawler(i) = crawler(i-1) - decay;
        
        % - Increment delay -
        delay = delay + 1;
    end
    
end

figure(7)
plot(t(1:N-1), y(1:N-1), 'b');
hold on
plot(t(1:N-1), crawler, 'r');

L=length(ptp_time);
%calculate pulse in real time
for i=1:(L-1)
    pulse_real_time(i)=60/(ptp_time(i+1)-ptp_time(i));
end

% l_ref=length(ref);
% for i=1:(l_ref-1)
%     pulse_real_ref(i)=60/(ref(i+1)-ref(i));
% end

pulse=mean(pulse_real_time(3:end))
% pulse_ref=mean(pulse_real_ref(3:end))

figure(8)
plot(ptp_time(1:L-1),pulse_real_time) %, 'b',ref(1:l_ref-1), pulse_real_ref, 'r')

