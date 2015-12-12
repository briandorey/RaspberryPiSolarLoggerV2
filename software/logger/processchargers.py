#!/usr/bin/python
#
# Python script to read bluetooth serial data from USB Smart Chargers
# from http://briandorey.com/post/usb-smart-charger-with-bluetooth-le.aspx
#
# run every 5 mins with cron
# sudo crontab -e
# */5 * * * * python /home/pi/processchargers.py &
#
import urllib2
import serial
import time

# url for processing page
url = 'http://10.0.0.25/processcharger.aspx?'
#Open named port and set baud rate to 115200
ser = serial.Serial ("/dev/ttyACM0", 115200, timeout=2)    
ser.open()

   
   
def sendbasiccommand(theinput):
  ser.flushInput()
  ser.flushOutput()
  ser.write(theinput.encode())
  return ser.read(512)
  
  
# function to send commands to the bluetooth module and return full response from first line
def sendcommand(theinput):
  ser.flushInput()
  ser.flushOutput()
  time.sleep(0.25)
  ser.write(theinput.encode())
  time.sleep(0.25)
  buffer_string = ''
  while True:
    buffer_string = buffer_string + ser.read(ser.inWaiting())
    if '\n' in buffer_string:
      lines = buffer_string.split('\n')
      return lines[0]       

# function to send data requests to the bluetooth module and return trimmed response
def sendreceivedata(theinput):
  counter = 0
  theinput = theinput + '\r'
  try:
    ser.flushInput()
    ser.flushOutput()
    ser.write(theinput.encode())
    time.sleep(0.1)
    buffer_string = ''
    while True:
      buffer_string = buffer_string + ser.read(ser.inWaiting())
      if '\r' in buffer_string:
        lines = buffer_string.split('\r')
        return lines[0].replace(".","").replace("R,","").replace("\r,","")
      counter = counter + 1
      if counter > 100:
        break
  except:
    return "Error with data"     
    
def getChargerData(chargerid):
  datastr = ''
  chargepower = 0
  
  if 'AOK' in sendcommand("E,0," + chargerid + "\r"):
    print 'connected'
    time.sleep(0.25)
    try:
      tempval = sendreceivedata("CHR,001A")
      chargepower = float(tempval)
      #chargepower = float(sendreceivedata("CHR,001A"))
    except:
      print "Not a float"
    print "Power: %s" % chargepower
    if chargepower > 10:
      datastr += 'chargerid=%s' % chargerid
      datastr += '&001A=%s' % sendreceivedata("CHR,001A") # ServiceChargingPower 10
      datastr += '&0026=%s' % sendreceivedata("CHR,0026") # ServiceTotalCharge 10
      datastr += '&0024=%s' % sendreceivedata("CHR,0024") # ServiceStartTime 14
      datastr += '&0028=%s' % sendreceivedata("CHR,0028") # ServiceEndTime 14
    
      #datastr += '&0018=%s' % sendreceivedata("CHR,0018") # ServiceDate 14
      #datastr += '&001C=%s' % sendreceivedata("CHR,001C") # ServiceActive 4
      #datastr += '&001E=%s' % sendreceivedata("CHR,001E") # ServicePowerDownVoltage 10
      #datastr += '&0020=%s' % sendreceivedata("CHR,0020") # ServicePowerUpVoltage 10
      #datastr += '&0022=%s' % sendreceivedata("CHR,0022") # ServiceDeviceID 14

      print datastr
      time.sleep(1)
      sendcommand("K\r") #disconnect from device
      try:
        response = urllib2.urlopen(url + datastr)
        html = response.read()
        print html
      except:
        print "Unable to upload data"
    else:  
      sendcommand("K\r") #disconnect from device
      
  else:
    print "Error connecting to charger"
  



getChargerData("001EC01A6644") # brian
print "Charger 1 saved"

#time.sleep(5)

getChargerData("001EC025F3A5") # Andrew
print "Charger 2 saved"

#time.sleep(5)

getChargerData("001EC01A663D") # living room
print "Charger 3 saved"

# test functions to get devices and services
#print sendbasiccommand("f\r") # scan for available devices
#time.sleep(1)
#print sendreceivedata("LC\r") # list available services

ser.close()
print "Finished"
