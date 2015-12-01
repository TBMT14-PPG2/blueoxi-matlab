function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 18-Nov-2015 15:22:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;
handles.signal_loaded=0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%Show our logo in axes 4
g= imread('Logo.png');
axes(handles.logo)
imshow(g);

% % Try to change the size on the toolbar
% hToolbar = findall(gcf,'tag','FigureToolBar');
% jToolbar = get(get(hToolbar,'JavaContainer'),'ComponentPeer');
% jToolbar.setPreferredSize(java.awt.Dimension(10,50));
% jToolbar.revalidate; % refresh/update the displayed toolbar


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in load.
function load_Callback(hObject, eventdata, handles)
% hObject    handle to load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.signal_loaded==1
    set(handles.pulse_value, 'String', '');
    set(handles.max_pulse_value, 'String', '');
    set(handles.oxy_value, 'String', '');
    cla(handles.oxy_graph,'reset')
    cla(handles.waveform_graph,'reset')
    guidata(hObject,handles);
    
    filename=uigetfile('*.wav');
    [Y, Fs]=audioread(filename);
    [avg_pulse, sig, BPM]=func_pulsecalc(Y, Fs);
    handles.signal=Y;
    handles.filtered_sig=sig;
    handles.Fs=Fs;
    handles.signal_loaded=1;
    guidata(hObject,handles);
else
    filename=uigetfile('*.wav');
    [Y, Fs]=audioread(filename);
    [avg_pulse, sig, BPM]=func_pulsecalc(Y, Fs);
    handles.signal=Y;
    handles.filtered_sig=sig;
    handles.Fs=Fs;
    handles.signal_loaded=1;
    guidata(hObject,handles);
    
    % axes(handles.waveform_graph)
    % plot(filtered_signal);
    % handles.waveform_graph=gca;
end

% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.signal_loaded==0
   msgbox('No signal loaded')
   return
end

% Checks if the entered film length is a number
if isnan(str2double(get(handles.age,'String'))) == 1
    msgbox('Age must be a number')
   return
else
    age =(str2double(get(handles.age, 'String')));
    % Checks if the entered number is between 0 and 100 years
    if age > 100 && age < 0
        msgbox('Age must be between 0 and 100 years', 'Status');
        return
    end
end

% Take out the variables and plot the waveform
    [avg_pulse, sig, BPM, S, S_avg, ptp_time]=func_pulsecalc(handles.signal, handles.Fs);
 %   handles.filter_sig = sig;
    t=[0:1/handles.Fs:(length(sig)-1)/handles.Fs];
 %        handles.t=[0:1/handles.Fs:10];
%     sig=1:length(t);
%     plot(handles.waveform_graph,t(i:i+100),sig(i:i+handles.Fs/10));
      plot(handles.waveform_graph,t, sig);%(1:length(handles.t)));
      Ax = findall(0,'type','axes');
       axis(Ax(3),[0 10 0 4.5e-3]);
      

 % Call back function displays the current slider value & plots n points
%     function callbackfn(handles.slider2,eventdata)
%  m=get(slider_handle, 'Value');
% set(value_slide,'String',num2str(m))
% plot(handles.waveform_graph,handles.t, m*sig(1:length(handles.t)));

% for i=1:handles.Fs/10:(length(handles.signal)-handles.Fs/10)
%     tic;
%     timer=tic;
%      handles.waveform_graph = get(handles.slider2,'Value');
%      m=get(handles.slider_handle, 'Value');
%      set(value_slide,'String',num2str(m))
     
    %Display the value of the current pulse in tag pulse_value
    set(handles.text20, 'String', 'Avg pulse bpm:');
    set(handles.pulse_value, 'String', BPM);
    
    %Display the value of the maximum pulse in tag max_pulse_value
    max_pulse = 220-age;
    percent_max_pulse = round(BPM/max_pulse*100);
    % S = sprintf('%d', 60);
    set(handles.max_pulse_value, 'String', percent_max_pulse);
    
    %Display the value of the current oxy_sat in tag oxy_value
    % S = sprintf('%d', 98);
    set(handles.text21, 'String', 'Average SpO2:');
    set(handles.oxy_value, 'String', S_avg);
    
    %Show BPM and O2 in axes2 with tag oxy_graph
    axes(handles.oxy_graph)
    le=1:length(avg_pulse);
    le_ss=1:length(S);
    le_s=le_ss/handles.Fs;
    [ax,p1,p2] = plotyy(ptp_time,avg_pulse,le_s,S,'semilogy','plot');
    xlabel(ax(1),'Time [s]') % label x-axis
    ylabel(ax(1),'BPM') % label left y-axis
    ylabel(ax(2),'% O2') % label right y-axis
%     ylim([30 200])
%     ylim(ax(2),[60 110]);
%     line(le_s,S,'Color','b')
%     ax(2).XColor = 'b';
%     ax(2).YColor = 'b';
    line(ptp_time,avg_pulse,'Color','k')
    ax(1).XColor = 'k';
    ax(1).YColor = 'k';

% pause(1/(handles.Fs/10) - toc(timer));
% end


function age_Callback(hObject, eventdata, handles)
% hObject    handle to age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of age as text
%        str2double(get(hObject,'String')) returns contents of age as a double


% --- Executes during object creation, after setting all properties.
function age_CreateFcn(hObject, eventdata, handles)
% hObject    handle to age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in stop_buttom.
function stop_buttom_Callback(hObject, eventdata, handles)
% hObject    handle to stop_buttom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

   set(handles.pulse_value, 'String', '');
   set(handles.max_pulse_value, 'String', '');
   set(handles.oxy_value, 'String', '');
   cla(handles.oxy_graph,'reset')
   cla(handles.waveform_graph,'reset')
   guidata(hObject,handles);
  
% --- Executes on button press in record.
function record_Callback(hObject, eventdata, handles)
% hObject    handle to record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 axes(handles.waveform_graph)
    delete(instrfindall);
    clear s;
    instrreset;
    s = tcpip('0.0.0.0', 2222, 'NetworkRole', 'server');

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
    plotCnt=1;

    redSig=[];
    irSig=[];
    sig_red=[];
    sig_ir=[];
    k=150;
    Fs=500;
    age =(str2double(get(handles.age, 'String')));
    MaxPulse=220-age
    PercentageOfMax=round(1000*60/MaxPulse)/10;
    five_pulses=60*ones(1,5);
    Pulse=60;
    lastpeaktime=0;
    t=[0:1/500:35/500];
    filt=fir1(34, [0.5 10]/(Fs/2));
    redSig=zeros(1,35);
    filtered=t;
    count=0;
    ptp_time=0;
    AC_red=0;
    DC_red=0;
    ACfull=0;
    DCfull=0;
    AC_IR=0;
    DC_IR=0;
    R=1;
    newR=1;

    axes(handles.waveform_graph) 
    handles.waveform_graph=plot(t,filtered,'-k','LineWidth',1.5);

while(1)
    
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
                
               if mod(plotCnt, 1)==0
               
                for i=length(redSig)-length(red)-length(filt)+1:length(redSig)-length(filt)
                    filtered(i)=2^16-sum(redSig(i:i+length(filt)-1).*filt);
                    %filteredIR(i)=sum(irSig(i:i+length(filt)-1).*filt);
                    t(i)=i/500;
                end
                count=round(t(end)*500);
            
                save Data filtered AC_red DC_red AC_IR DC_IR redSig irSig R ptp_time t

                     if t(end)>4
                     
                     set(handles.waveform_graph,'XData',t(t > t(end-2000+1)),'YData',filtered(t>t(end-2000+1)))
                     axis([t(end-2000+1) t(end) min(filtered(end-2000:end))-2 max(filtered(end-2000:end))+2])
             
                     for i=count-length(red)-k:count-k
                         
                       if t(i-k)>lastpeaktime+30/Pulse(end)
                             
                        if ( ( filtered(i-k)>=max(filtered(i-k+1:i)) )  && ...
                           (  filtered(i-k)>=max(filtered(i-2*k:i-k-1)) ) )
                            
                            hold on
                            scatter(t(i-k),filtered(i-k),'or','fill')
                            lastpeaktime=t(i-k);
                            ptp_time = [ptp_time lastpeaktime];
                            five_pulses=[five_pulses(2:5) 60/(ptp_time(end)-ptp_time(end-1))];
                            Pulse=[Pulse round(mean(five_pulses))];
                            PercentageOfMax=[PercentageOfMax round(100*Pulse(end)/MaxPulse)]; 
                            AC_red=[AC_red max(redSig(i-500:end-100))];
                            DC_red=[DC_red min(redSig(i-500:end-100))];
                            AC_IR=[AC_IR max(irSig(i-500:end-100))];
                            DC_IR=[DC_IR min(irSig(i-500:end-100))];
                            newR=((AC_red(end)-DC_red(end))/DC_red(end))/((AC_IR(end)-DC_IR(end))/DC_IR(end));
                            R=[R 0.8*R(end)+0.2*newR];
                            set(handles.pulse_value, 'String', Pulse(end));
                            set(handles.max_pulse_value, 'String', PercentageOfMax(end));
                            plot(handles.oxy_graph,ptp_time,Pulse,'-k',ptp_time,PercentageOfMax,'-r',ptp_time,R,'-b','LineWidth',1.5);
                        end
                      end
                     end
                  end
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

% --- Executes on button press in Forward.
function Forward_Callback(hObject, eventdata, handles)
% hObject    handle to Forward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
         Ax = findall(0,'type','axes');
         xl=xlim(Ax(4));
         if xl(2)<(length(handles.filtered_sig)/handles.Fs)
         axis(Ax(4),[xl(1)+1 xl(2)+1 0 4.5e-3])
         end

% --- Executes on button press in backward.
function backward_Callback(hObject, eventdata, handles)
% hObject    handle to backward (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Ax = findall(0,'type','axes');
         xl=xlim(Ax(4));
         if xl>0
         axis(Ax(4),[xl(1)-1 xl(2)-1 0 4.5e-3])
         end
         
         
         
         
