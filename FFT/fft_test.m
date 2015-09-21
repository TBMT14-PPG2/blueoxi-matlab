clear
load('0038_8min.mat')
% plot([1:length(signal.pleth.y)]/param.samplingrate.pleth,signal.pleth.y)
% plot(signal.pleth.y)
% figure(2)
% plot([1:length(signal.pleth.y)]*param.samplingrate.pleth/length(signal.pleth.y),abs(fft(detrend(signal.pleth.y))))

signal = detrend(signal.pleth.y);
fs = param.samplingrate.pleth;
BPM = [];
   for i=1:200:length(signal)-2000
    length_window=2001;
    W = window(@hamming,length_window);
    Window = signal(i:2000+i).*W;
    Y = fft(Window);
    [M, I] = max(abs(Y));
    BPM = [BPM, I*fs/length(Y)*60];
   end
 
   plot((1:length(Y))/length(Y)*fs,abs(Y))
   plot(BPM)
   
   %%
   subplot(2,1,1)
   plot(BPM)
   
   subplot(2,1,2)
   plot(signal)
   
   %% Find peaks
   
   for k = 1:lenght(signal)
   if signal(k) >= signal(k+1) && signal(k) > signal(k-1)
       for i = signal(k):signal(k+15)
       if signal(k) ~= signal(k+i)
           
       end
   