[Y, Fs]=audioread('ppg1.wav');
X=Y(:,1);

 [y,AC, DC]=Filter_PPG(X);
k=700;
for i=1:(length(y)-k)
        
        if i<k+1
            peakmatch(i)=max(y(i:i+k));
        else
 peakmatch(i)=max(y(i-k:i+k));

            peakmatch(1:end); 
        end
end
peaks= zeros(1, length(peakmatch));
for i =1: length(peakmatch)
    if peakmatch(i)==y(i)
        peaks(i)=y(i);
    end
end

beatcount=-1;
for k = 2:length(peaks)-1
   if peaks(k) >= peaks(k-1) && peaks(k) > peaks(k+1)
       beatcount= beatcount + 1;
   end
end
samples= length(peaks);
duration_in_sec= samples/Fs;
duration_in_min= duration_in_sec/60;
BPM= beatcount/duration_in_min

figure(444)
subplot(2,1,1)
plot(y)
hold on
plot(peakmatch)
hold off
subplot(2,1,2)
plot(peaks)
