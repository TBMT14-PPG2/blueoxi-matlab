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

% Last Modified by GUIDE v2.5 13-Nov-2015 11:25:06

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

filename=uigetfile('*.wav');
[Y, Fs]=audioread(filename);
%[avg_pulse, sig, BPM]=func_pulsecalc(Y, Fs);
handles.signal=Y;
handles.Fs=Fs;
handles.signal_loaded=1;
guidata(hObject,handles);

% axes(handles.waveform_graph)
% plot(filtered_signal);
% handles.waveform_graph=gca;

% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.signal_loaded==0
     delete(instrfindall);

    serialPort = 'COM3';            

    Min_waveform = -10;                    
    Max_waveform = 10;
    Min_pulse = 0;                    
    Max_pulse = 150;
   
    timeint = 10;
    delay = .0000001;                   

    elements_saved=160; %nr of elemetns saved and used for calculation
    k=round(elements_saved/3);
    LP=zeros(1,elements_saved); %vector to make calculations on
    time = 0;
    data = 0;
    count = 2*k;

    ptp_time=0;
    lastpeaktime=0;
    five_pulses=60*ones(1,5);
    avg_pulse=60;
    Pulse=60;
    PercentageOfMax=0;
    
    %Set graph properties
    
    axes(handles.oxy_graph)
    handles.oxy_graph = plot(ptp_time,Pulse,'-k','LineWidth',1.5);
    title('Pulse','FontSize',15);
    xlabel('Time [S]','FontSize',8);
    ylabel('BPM','FontSize',8);
    axis([0 10 Min_pulse Max_pulse]);
    
    axes(handles.waveform_graph)
    handles.waveform_graph = plot(time,data,'-k','LineWidth',1.5);
    title('PPG Waveform','FontSize',15);
    xlabel('Time [S]','FontSize',8);
    ylabel('Amplitude','FontSize',8);
    axis([0 10 Min_waveform Max_waveform]);

    s = serial(serialPort);
    fopen(s);
    tic 
    
    
    
    fprintf(s,'a');
    while ishandle(handles.waveform_graph) %Loop when Plot is Active

        USB_Data = fscanf(s,'%e'); %Read Data from Serial as Float

        LP=[LP(2:end) USB_Data(1)]; 
        value=mean(LP(k-5:k+4)); %averaging over 10 data samples
        DC_val=min(LP);
        AC_val=max(LP)-DC_val;
        filtval(count+1)=value-DC_val-AC_val/2; %remove most of baseline wander
        DC(count+1)=DC_val;
        AC(count+1)=AC_val;
        peakmatch=AC_val+DC_val; %max(LP)



        if(~isempty(USB_Data) && isfloat(USB_Data)) %Check if correct data from USB       
            count = count + 1;  %increases for each data received
            time(count) = toc;  %set time
            data(count) = filtval(count); %set data to filtered value
    %         data(count) = USB_Data(1);

            %Set Axis according to Scroll Width
            if(timeint > 0)
            %axes(handles.waveform_graph)
            set(handles.waveform_graph,'XData',time(time > time(count-k)-timeint),'YData',data(time > time(count-k)-timeint));
            %plot(handles.waveform_graph,time(time > time(count-k)-timeint),data(time > time(count-k)-timeint));
            axis([time(count-k)-timeint time(count-k) Min_waveform Max_waveform]);

                % Check for peak
                if ( filtval(count-k)>=max(filtval(count-(k-1):count)) && ...
                     filtval(count-k)>max(filtval(count-2*k:count-(k+18))) &&...
                     time(count-k)>lastpeaktime+round(30/Pulse(end)) ) 

                    hold on
                    scatter(time(count-k),data(count-k),'or','fill')
                    lastpeaktime=time(count-k);
                    ptp_time = [ptp_time lastpeaktime];
                    five_pulses=[five_pulses(2:5) 60/(ptp_time(end)-ptp_time(end-1))];
                    avg_pulse=[avg_pulse mean(five_pulses)];
                    Pulse=[Pulse round(avg_pulse(end))];
                    PercentageOfMax=[PercentageOfMax round(1000*Pulse(end)/195)/10]; %max pulse=195 BPM
                    
                    set(handles.pulse_value, 'String', Pulse(end));
                    set(handles.max_pulse_value, 'String', PercentageOfMax(end));
                    
                    %axes(handles.oxy_graph)
                    %set(handles.oxy_graph,'CurrentAxes')
                    %plot(handles.oxy_graph,'XData',ptp_time,'YData',Pulse);
                    %axes(handles.waveform_graph)
               
                    
                end
                
                
            
%             set(handles.oxy_graph,'XData',time,'YData',Pulse);
%             axis([time(count-k)-timeint time(count-k) Min_waveform Max_waveform]);

            else
            set(plotGraph,'XData',time,'YData',data);
            axis([0 time(count) Min_waveform Max_waveform]);
            end


            pause(delay);
        end
    end

    %Close Serial COM Port
    fclose(s);
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

% for i=1:handles.Fs/10:(length(handles.signal)-handles.Fs/10)
%     tic;
%     timer=tic;

    [avg_pulse, sig, BPM, S, S_avg]=func_pulsecalc(handles.signal, handles.Fs);
%    t=[0:1/handles.Fs:(length(sig)-1)/handles.Fs];
         t=[0:1/handles.Fs:10];
%     sig=1:length(t);
%     plot(handles.waveform_graph,t(i:i+100),sig(i:i+handles.Fs/10));
     plot(handles.waveform_graph,t, sig(1:length(t)));
     
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
    le_s=1:length(S);
    [ax,p1,p2] = plotyy(le/handles.Fs,avg_pulse,le_s/handles.Fs,S,'semilogy','plot');
    xlabel(ax(1),'Time [s]') % label x-axis
    ylabel(ax(1),'BPM') % label left y-axis
    ylabel(ax(2),'% O2') % label right y-axis
%     ylim([30 200])
%     ylim(ax(2),[60 110]);
    line(le,avg_pulse,'Color','k')
    ax(1).XColor = 'k';
    ax(1).YColor = 'k';
%     line(le_s,S,'Color','r')
%     ax(2).XColor = 'r';
%     ax(2).YColor = 'r';

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
