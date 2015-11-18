clear all
delete(instrfindall);
s = serial('COM3');

set(s, 'InputBufferSize', 256);
set(s, 'BaudRate', 115200);
fopen(s);

packet = zeros(1, 4);
pCnt = 1;
state = 1;
cnt = 0;
len = 0;
sCnt=1;
j=1;
tempLrc=0;
s1Cnt=1;
bCnt=0;
byteCnt=1;
plotCnt=0;

redSig=[];
irSig=[];



for i = 1:20000
    
    if s.BytesAvailable > 0
       byte_array=fread(s, s.BytesAvailable, 'uchar'); 
       bCnt=length(byte_array);
       byteCnt=1;
    end
    
    while bCnt >0              
        byte = byte_array(byteCnt);
        byteCnt=byteCnt+1;
        bCnt=bCnt-1;
        
        
        switch state
            % Preable
            case 1
                if(byte == 165)   %hex: 0xA5
                    packet(pCnt) = byte;
                    pCnt=pCnt+1;
                    state = 2;
                end
                % Cmd + Param
            case 2
                cnt=cnt+1;
                packet(pCnt) = byte;
                pCnt=pCnt+1;
                if(cnt == 2)
                    state = 3;
                    cnt = 0;
                end
                % Len
            case 3
                packet(pCnt) = byte;
                pCnt=1;
                len = byte;
                state = 4;
                % LRC
            case 4
                x = mod(sum(packet), 256) ;
                lrc=bitcmp(x, 'uint8')+1;
                   
                if(byte == lrc)
                    state = 5;
                    lrc=0;
                else
                    state = 1;
                end
            case 5
                
                    tempLrc = tempLrc + byte;
                    
                    if sCnt==1
                        sample(j)=byte; %*256;
                        sCnt=sCnt+1;
                    elseif sCnt==2
                        sample(j)=sample(j)+byte*256;
                        sCnt=1;
                        j=j+1;
                    end
                    
                    s1Cnt=s1Cnt+1;

                
                    if s1Cnt==len+1  
               
                        state=6;
                        s1Cnt=1;
                        j=1;
                    else
                        state=5;
                    end
                    
                
            case 6
                x2 = mod(tempLrc, 256) ;
                tempLrc=0;
                lrc2=mod((bitcmp(x2, 'uint8')+1), 256);
                
                if(byte == lrc2)
                    state = 7;
                    lrc2=0;
                else
                    state = 1;
                end
                
            case 7
                             
                red=sample(1:2:end);
                ir=sample(2:2:end);
                
                redSig=[redSig red];
                irSig =[irSig ir];
                
                if mod(plotCnt, 5)==0
                    t=1:length(redSig);
                    plot(t, redSig, t, irSig)
                end
                
                pause(0.0001)
                plotCnt=plotCnt+1;
                
                
                state=1;
                     
               
            otherwise
                disp('done')
        end
        
    end
end





fclose(s);
delete(s);
clear s;

