function [ Generated_PPG_signal ] = Func_ppg( DC, AC )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

noise=1;    %Noise amplitude
%DC=15;      %DC amplitude
%AC=1;       %AC amplitude
DN=1;       %Dicrotic notch size
fluctuation=0;  %Fluctiation amplitude
samplingrate=60;
heartrate=60;
time=10;    %Seconds

t=0:1/samplingrate:time;
a=4*sin(t*2*pi*heartrate/60)+4;
b=sin(t*2*pi*heartrate/60+pi*1.4)*4-3.5;


for i=1:length(a)
    if a(i)<0
        a(i)=0;
    end
end

for i=1:length(b)
    if b(i)<0
        b(i)=0;
    end
end
    
c=AC*(a+DN*b*4);
%---------Add noise

c=c+noise*rand(1,length(c))/2;

%---------Add DC

c=c+DC;
%--------Add fluctuation

if fluctuation ~= 0
    F=0.05*sin(t/2)+1;
    c=fluctuation*c.*F;
end

Generated_PPG_signal=c;  %Final generated PPG signal
end

