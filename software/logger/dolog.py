#!/usr/bin/python

from ABE_ADCDifferentialPi import ADCDifferentialPi
from ABE_helpers import ABEHelpers
import time
import os
import RPi.GPIO as GPIO
import datetime
import urllib2
import subprocess


# mount owfs
subprocess.call(["/opt/owfs/bin/owfs", "--i2c=ALL:ALL", "--allow_other", "/mnt/1wire/"])

# read sensors from https://www.wirelessthings.net/wireless-temperature-sensor
# using USB wireless dongle SRF Stick - USB Radio (868-915Mhz)
# https://www.wirelessthings.net/srf-stick-868-915-mhz-easy-to-use-usb-radio
# and display to screen, each sensor has an ID starting with:
# TA, TB or TC

import serial 
baud = 9600 
port = '/dev/ttyAMA0' 
ser = serial.Serial(port, baud) 
ser.timeout = 2 

# Setup ADC Chip
i2c_helper = ABEHelpers()
bus = i2c_helper.get_smbus()
adc = ADCDifferentialPi(bus, 0x6a, 0x6a, 16)


# Setup GPIO pin to read pump running status
GPIO.setmode(GPIO.BCM)
GPIO.setup(19, GPIO.IN, pull_up_down = GPIO.PUD_DOWN)

# 1 wire temperature sensors
path1="/mnt/1wire/28.5B7DC4030000/temperature"
path2="/mnt/1wire/28.8C37C4030000/temperature"
path3="/mnt/1wire/28.611555030000/temperature"
path4="/mnt/1wire/28.8945C4030000/temperature"

# setup variables with default values
varCurrentMinute = 0
varPrevMinute = 0
varNow = datetime.datetime.now()
varPumpRunning = 0
varDCVolts = 0.0
varDCAmps = 0.0
varPVAmps = 0.0

varTempHome1 = 0.0
varTempHome2 = 0.0
varTempHome3 = 0.0

varTempBase = 0.0
varTempBaseNew = 0.00
varTempTop = 0.0
varTempTopNew = 0.00
varTempCollector = 0.0
varTempCollectorNew = 0.00

# print("Logging Started")

# Function to read 1-Wire sensors using OWFS
def get1wiretempreading(path):
    try:
        time.sleep(2)
        f = open(path,"r")
	text = f.readlines()
	#f.close()
	return float(text[0]) + 3
    except:
	print ("getwiretemp failed")		
	return 88

# Function to upload data to online server		
def DoUpload():
    # do server update to server ip and processing page
    try:
        response = urllib2.urlopen('http://10.0.0.99/processgeneral.aspx?'
	+ 'watertop=' + str(varTempTop)
	+ '&waterbase=' + str(varTempBase)
	+ '&waterpanel=' + str(varTempCollector)
	+ '&hometemp1=' + str(varTempHome1)
	+ '&hometemp2=' + str(varTempHome2)
	+ '&hometemp3=' + str(varTempHome3)
	+ '&solarc=' + str(varPVAmps)
	+ '&batteryv=' + str(varDCVolts)
	+ '&offgridc=' + str(varDCAmps)
	+ '&pump=' + str(varPumpRunning)
	+ '')
		
        print (response)
    except:
        print ("http connection failed")
			
# Functions for formatting PV and battery values from ADC			
def formatBatteryVoltage(val):
    return val * 9.33
    
def formatInverterCurrent(val):
    return val * 19.5
    
def formatHouseCurrent(val):
    return val * 19.5
  
			
# Main program loop

while (True):

    # clear the console
    os.system('clear')


    # read from adc channels and save to variables
    
    varPVAmps = formatInverterCurrent(adc.read_voltage(1))
    varDCAmps =  formatHouseCurrent(adc.read_voltage(2))
    varDCVolts = formatBatteryVoltage(adc.read_voltage(3))
    
    # print ("Inverter: %.2f" % varPVAmps)
    # print ("Home: %.2f" % varDCAmps)
    # print ("Battery Voltage: %.2f V" % varDCVolts)
    # print ("System Current: %.2f A" % adc.read_voltage(4))
    
    # print("varTempHome1: %.2f" % varTempHome1)
    # print("varTempHome2: %.2f" % varTempHome2)
    # print("varTempHome3: %.2f" % varTempHome3)
    
    # print("varTempBase: %.2f" % varTempBase)
    # print("varTempTop: %.2f" % varTempTop)
    # print("varTempCollector: %.2f" % varTempCollector)
    
    if(GPIO.input(19) ==1):
        varPumpRunning = 1
        # print("Pump Running")
    if(GPIO.input(19) == 0):
        varPumpRunning = 0
        # print("Pump Off")

    # read 1-Wire sensors and update values if not error value (85 + 3 caculation factor)
    varTempBaseNew = get1wiretempreading(path2)
    if (varTempBaseNew != 88):
        varTempBase = varTempBaseNew
   
    varTempTopNew = get1wiretempreading(path4)
    if (varTempTopNew != 88):
        varTempTop = varTempTopNew
		
    varTempCollectorNew = get1wiretempreading(path1)
    if (varTempCollectorNew != 88):
        varTempCollector = varTempCollectorNew

    # Check for serial data and process if available
    if ser.inWaiting() >= 12: 
        if ser.read() == 'a':
    	    resultvalue = ser.read(11)
    	    if resultvalue is not None:
	        if resultvalue.startswith("TBTEMP"):
	    	    varTempHome1 = round(float(resultvalue.replace("TBTEMP", "")),2)
	    	    #print("TB Living Room: %" % varTempHome1)
	    			
	    	if resultvalue.startswith("TATEMP"):
	    	    varTempHome2 = round(float(resultvalue.replace("TATEMP", "")),2)
	    	    #print("TA Andrew Bedroom: %" % varTempHome2)
	    
	    	if resultvalue.startswith("TCTEMP"):
	    	    varTempHome3 = round(float(resultvalue.replace("TCTEMP", "")),2)
		    #print("TC Brian Bedroom: %" % varTempHome3)
		    
            
    # get current datetime and see if minute is different to previous minute
    varNow = datetime.datetime.now()
    #print (str(varNow))
    varCurrentMinute = varNow.minute
    if (varCurrentMinute != varPrevMinute):
        varPrevMinute = varCurrentMinute
    	DoUpload()
    # sleep for 1 second and repeat	
    time.sleep(1)


GPIO.cleanup()