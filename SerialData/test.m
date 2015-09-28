clear;
clc;

s = BOSerialData();
s.setPortName('/dev/tty.usbmodem411');
s.mPortName
s.open();

s.plot();

s.close();
