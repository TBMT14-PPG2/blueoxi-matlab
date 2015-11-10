function [ Y, AC, DC ] = Filter_PPG( signal )

    n=200;
    
    filtered_signal=zeros(1,length(signal)-n);

    for i=1:(length(signal)-n)

        filtered_signal(i)=mean(signal(i:i+n));

    end


    
    k=800;
    
    filtered_signal2=zeros(1,length(filtered_signal)-k);
    AC=zeros(1,length(filtered_signal)-k);
    DC=zeros(1,length(filtered_signal)-k);
    
    for i=1:(length(filtered_signal)-k)
        
        if i<k+1
            DC(i)=min(filtered_signal(i:i+k));
            AC(i)=max(filtered_signal(i:i+k))-min(filtered_signal(i:i+k));
        else

           
            DC(i)=min(filtered_signal(i-k:i+k));
            AC(i)=max(filtered_signal(i-k:i+k))-min(filtered_signal(i-k:i+k));

            filtered_signal2(i)=filtered_signal(i)-DC(i)-AC(i)/2;
        end
    
    end
    filtered_signal2=filtered_signal2+abs(min(filtered_signal2));
    Y=max(filtered_signal2)-filtered_signal2;  %flip signal
    
%     figure
%     subplot(3,1,1)
%     plot(signal)
%     axis([0 length(signal) min(signal) max(signal)])
%     subplot(3,1,2)
%     plot(filtered_signal)
%     axis([0 length(filtered_signal) min(filtered_signal) max(filtered_signal)])
%     hold;
%     plot(DC+AC,'G')
%     plot(DC,'R')
% 
%     subplot(3,1,3)
%     plot(filtered_signal2)
%     axis([0 length(Y) min(Y) max(Y)])
   
end
