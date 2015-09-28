classdef BOSerialData < handle
    properties
        mSerial;
        mPortName;
        mFigure;
        mPlot;
        mTime = 0;
        mData = 0;
        mSamples = 2048;
    end
    methods
        % Constructor
        function self = BOSerialData()
            
            % Set up plot
            self.mFigure = figure('visible','on');
            self.mPlot = plot(self.mTime,self.mData,...
                '-b',...
                'LineWidth',1);
            xlabel('Time [s]','FontSize',15);
            ylabel('Amplitude [arb. unit]','FontSize',15);
            %axis([0 samples min max]);
            grid('on');
            %saveas(self.mFigure,'BOSerialData-Plot','fig')
        end
        
        % Set serial port
        function setPortName(self, portName)
            self.mPortName = portName;
        end
        
        % Open serial port
        function open(self)
            delete(instrfindall);
            self.mSerial = serial(self.mPortName);
            fopen(self.mSerial);
            fprintf(self.mSerial,'a');
        end
        
        % Close serial port
        function close(self)
            self.mSerial = serial(self.mPortName);
            fopen(self.mSerial);
        end
        
        % Plot serial data
        function plot(self)
            % Define local variables
            updateCounter = 0;
            dataSample = 0;
            sampleCounter = 0;
            
            % Start timer
            tic;
            
            self.mData = zeros(1,self.mSamples);
            self.mTime = 1:self.mSamples;
            
            % Plot until the plot is closed
            while ishandle(self.mPlot)
                updateCounter = updateCounter + 1;
                % Update
                if updateCounter > 100
                    updateCounter = 0;
                    
                    % Redraw plot
                    set(self.mPlot,'XData',self.mTime,'YData',self.mData);
                    pause(0.0001);
                end
                
                dataSample = fscanf(self.mSerial,'%d');
                if(~isempty(dataSample))
                    sampleCounter = mod(sampleCounter + 1, self.mSamples);
                    self.mData(sampleCounter+1) = dataSample(1);
                    pause(0.0001);
                end
            end
        end
    end
end