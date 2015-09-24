classdef BOSerialData < handle
    properties
        mSerial;
        mSerialPortName;
    end
    methods
        % Constructor
        function self = BOSerialData()
            
        end
        % Set serial port
        function setSerialPortName(self, portName)
            self.mSerialPortName = portName;
        end
    end
end