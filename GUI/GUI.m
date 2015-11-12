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

% Last Modified by GUIDE v2.5 10-Nov-2015 11:36:38

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
    msgbox('Please load a file');
    return    
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
    set(handles.pulse_value, 'String', BPM);
    
    %Display the value of the maximum pulse in tag max_pulse_value
    % S = sprintf('%d', 60);
    % set(handles.max_pulse_value, 'String', S);
    
    %Display the value of the current oxy_sat in tag oxy_value
    % S = sprintf('%d', 98);
    set(handles.oxy_value, 'String', S_avg);
    
    %Show BPM and O2 in axes2 with tag oxy_graph
    axes(handles.oxy_graph)
    le=1:length(avg_pulse);
    le_s=1:length(S);
    [ax,p1,p2] = plotyy(le,avg_pulse,le_s,S,'semilogy','plot');
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

