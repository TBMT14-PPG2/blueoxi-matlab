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

% Last Modified by GUIDE v2.5 02-Dec-2015 13:49:07

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
g= imread('blueoxi_logo.png');
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

% see if a file is loaded, if it is the old file is removed and a new file
% is chosen.
if handles.signal_loaded==1
    set(handles.pulse_value, 'String', '');
    set(handles.max_pulse_value, 'String', '');
    set(handles.oxy_value, 'String', '');
    cla(handles.oxy_graph,'reset')
    cla(handles.waveform_graph,'reset')
    guidata(hObject,handles);
    
    filename=uigetfile('*.mat');
    load(filename)
    handles.pulse = Pulse;
    handles.saturation = Sat;
    handles.max_pulse = PercentageOfMax;
    handles.time_peak = ptp_time;
    handles.time_sig = t;
    handles.signal = filtered;
    set(handles.play, 'Enable', 'on');
    set(handles.play, 'Value', 0);
    handles.signal_loaded=1;
    guidata(hObject,handles);
    
else
    filename=uigetfile('*.mat');
    load(filename)
    handles.pulse = Pulse;
    handles.saturation = Sat;
    handles.max_pulse = PercentageOfMax;
    handles.time_peak = ptp_time;
    handles.time_sig = t;
    handles.signal = filtered;
    set(handles.play, 'Enable', 'on');
    set(handles.play, 'Value', 0);
    
    handles.signal_loaded=1;
    guidata(hObject,handles);
end

% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Looks if a file is loaded, otherwise a messagebox is appering.
if handles.signal_loaded==0
   msgbox('No signal loaded')
   return
end

% Plot the waveform in the first axes and showing a smal part of the signal
% at the time, with backward and forward button the whole signal can be
% visulized.
plot(handles.waveform_graph,handles.time_sig,handles.signal);
Ax = findall(0,'type','axes');
axis(Ax(3),[0 10 min(handles.signal(100:5000)) max(handles.signal(100:5000))]);

%Display the value of the average pulse in tag pulse_value
set(handles.text20, 'String', 'Avg pulse BPM:');
set(handles.pulse_value, 'String', round(mean(handles.pulse)));

%Display the value of the maximum pulse in tag max_pulse_value
set(handles.text19, 'String', 'Avg max pulse:');
set(handles.max_pulse_value, 'String', round(mean(handles.max_pulse)));

%Display the value of the average oxy_sat in tag oxy_value
set(handles.text21, 'String', 'Average SpO2:');
set(handles.oxy_value, 'String', round(mean(handles.saturation)));

%Show pulse and O2 in axes2 with tag oxy_graph
axes(handles.oxy_graph)
[ax,p1,p2] = plotyy(handles.time_peak,handles.pulse,handles.time_peak,handles.saturation,'semilogy','plot');
xlabel(ax(1),'Time [s]') % label x-axis
ylabel(ax(1),'BPM') % label left y-axis
ylabel(ax(2),'SPo2 [%]') % label right y-axis
set(handles.play, 'Enable', 'off');

function age_Callback(hObject, eventdata, handles)
% hObject    handle to age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function age_CreateFcn(hObject, eventdata, handles)
% hObject    handle to age (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Sets the condition for the age window
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in stop_buttom.
function stop_buttom_Callback(hObject, eventdata, handles)
% hObject    handle to stop_buttom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject,handles)
set(handles.stop_buttom, 'Value', 1);
guidata(hObject,handles)
%Construct a questdlg with three default options
choice = questdlg('Do you like to save?', 'Save dialog');

switch choice
    case 'Yes'
        uisave({'filtered', 'ptp_time', 'Pulse', 'PercentageOfMax', 'R','t'}); % Save Sat instead of R!
    case 'No'  
    case 'Cancel'
end
  
% --- Executes on button press in record.
function record_Callback(hObject, eventdata, handles)
% hObject    handle to record (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.waveform_graph)
delete(instrfindall);
clear s;
instrreset;

% WiFi
s = tcpip('0.0.0.0', 2222, 'NetworkRole', 'server');
set(s, 'InputBufferSize', 30000);
set(s, 'Terminator', '');

% USB
%s = serial('COM3');  %Change to the right serial port
%set(s, 'InputBufferSize', 256);
%set(s, 'BaudRate', '115200');

fopen(s);


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

% Declared variables
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
csig_ir=[];
k=300;
Fs=1000;

MaxPulse=220-age;
PercentageOfMax=round(1000*60/MaxPulse)/10;
five_pulses=60*ones(1,5);
Pulse=60;
lastpeaktime=0;
t=[0:1/500:35/500];
filt=fir1(34, [0.5 8]/(Fs/2)); 
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
R=1.6;
newR=1.6;
Sat=96;
newSat=96;
length_red=50;
Stop=0;
SecondsDisplayed=6; %Change to increase size of displayed window in real time

axes(handles.waveform_graph)
handles.waveform_graph=plot(t,filtered,'-k','LineWidth',1.5);


% Gets the data from the device into matlab while stopped button is not
% pressed.
%while handles.Stop == 0
while ~get(handles.stop_buttom, 'Value')
    
    
    if s.BytesAvailable > 0
        byte_array=fread(s, s.BytesAvailable, 'uchar');
        bCnt=length(byte_array);
        byteCnt=1;
    end
    
    while (bCnt >0 && ~get(handles.stop_buttom, 'Value'))
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
            
                ir=sample(1:2:end);
                redr=sample(2:2:end);
               
                redSig=[redSig red];
                irSig =[irSig ir];
                
                if mod(plotCnt, 1)==0
                    
                    for i=length(redSig)-length_red-length(filt)+1:length(redSig)-length(filt)
                        filtered(i)=2^16-sum(redSig(i:i+length(filt)-1).*filt);
                        t(i)=i/1000;
                    end
                    count=round(t(end)*1000);
                    
                    if (round(t(end)/10)==t(end)/10)
                        save Data filtered Pulse Sat PercentageOfMax t ptp_time
                        
                    end
                    
                    if t(end)>SecondsDisplayed+0.1
                        
                        xdata=t(t > t(end-Secondsdisplayed*1000+1));
                        ydata=filtered(t>t(end-Secondsdisplayed*1000+1));
                        set(handles.waveform_graph,'XData',xdata,'YData',ydata)
                        axis([xdata(1) xdata(end) min(ydata) max(ydata)])
                        
                        for i=count-length_red-k:count-floor(k/2)
                            
                            if t(i-k)>lastpeaktime+30/Pulse(end)
                            
                                    if ( ( filtered(i-k)>=max(filtered(i-k+1:i-k/2)) )  && ...
                                        (  filtered(i-k)>=max(filtered(i-2*k:i-k-1)) ) )
                                    
                                    hold on
                                    scatter(t(i-k),filtered(i-k),'or','fill')
                                    lastpeaktime=t(i-k);
                                    ptp_time = [ptp_time lastpeaktime];
                                    five_pulses=[five_pulses(2:5) 60/(ptp_time(end)-ptp_time(end-1))];
                                    Pulse=[Pulse round(mean(five_pulses))];
                                    PercentageOfMax=[PercentageOfMax round(100*Pulse(end)/MaxPulse)];
                                    max_red=max(redSig(i-1000:end));
                                    min_red=min(redSig(i-1000:end));
                                    max_IR=max(irSig(i-1000:end));
                                    min_IR=min(irSig(i-1000:end));    
                                    AC_red=max_red-min_red;
                                    DC_red=max_red;
                                    AC_IR=max_IR-min_IR;
                                    DC_IR=max_IR;
                                    newR=(AC_red(end)/DC_red(end))/(AC_IR(end)/DC_IR(end));
                                    newSat=-24*newR+112;
                                    Sat = [Sat round(0.95*Sat(end)+0.05*newSat)]; 
                                    set(handles.pulse_value, 'String', Pulse(end));
                                    set(handles.max_pulse_value, 'String', PercentageOfMax(end));
                                    set(handles.oxy_value, 'String', Sat(end));
                                    plot(handles.oxy_graph,ptp_time,Pulse,'-k',ptp_time,Sat,'-r','LineWidth',1.5);
                                  
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
    
    guidata(hObject,handles)
     if(get(handles.stop_buttom, 'Value')==1)
         break
     end;
end

%Construct a questdlg with three default options
choice = questdlg('Do you like to save?', 'Save dialog');

switch choice
    case 'Yes'
        %uisave({'filtered', 'ptp_time', 'Pulse', 'PercentageOfMax', 'Sat','t'});
        uisave filtered ptp_time Pulse PercentageOfMax Sat t
    case 'No'  
    case 'Cancel'
end

%Display the value of the current pulse in tag pulse_value
set(handles.text20, 'String', 'Avg pulse bpm:');
set(handles.pulse_value, 'String', mean(Pulse));

%Display the value of the maximum pulse in tag max_pulse_value
set(handles.text19, 'String', 'Avg percentage max pulse:');
set(handles.max_pulse_value, 'String', mean(PercentageOfMax));

%Display the value of the current oxy_sat in tag oxy_value
set(handles.text21, 'String', 'Average SpO2:');
set(handles.oxy_value, 'String', mean(R)); % Change to SpO2!!!

fclose(s);
delete(s);
clear s;

% --- Executes on button press in Forward.
function Forward_Callback(hObject, eventdata, handles)
% The forward button makes it possible to step forward in the signal
Ax = findall(0,'type','axes');
xl=xlim(Ax(4));
min_sig = min(handles.signal((xl(1)*500+1):(xl(2)*500)));
max_sig = max(handles.signal((xl(1)*500+1):(xl(2)*500)));
if xl(2)<(length(handles.signal)/500) % Fs = 500!
    axis(Ax(4),[xl(1)+1 xl(2)+1 min_sig max_sig])
end

% --- Executes on button press in backward.
function backward_Callback(hObject, eventdata, handles)
% The backward button makes it possible to step backward in the signal
Ax = findall(0,'type','axes');
xl=xlim(Ax(4));
min_sig = min(handles.signal((xl(1)*500+1):(xl(2)*500)));
max_sig = max(handles.signal((xl(1)*500+1):(xl(2)*500)));
if xl>0
    axis(Ax(4),[xl(1)-1 xl(2)-1 min_sig max_sig])
end

%  --- Executes on button press in Exit.
% By pressing exit button, the GUI window closes
function exit_botton_Callback(hObject, eventdata, handles)
clc
close all

% --- Executes on button press in Help.
% By pressing help button, a pdf file appears
function help_botton_Callback(hObject, eventdata, handles)
winopen('UserManual.pdf')

