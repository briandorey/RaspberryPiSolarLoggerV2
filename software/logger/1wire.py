#!/usr/bin/env python

import time
import subprocess

# 1 wire temperature sensors
path1="/mnt/1wire/28.5B7DC4030000/temperature"
path2="/mnt/1wire/28.8C37C4030000/temperature"
path3="/mnt/1wire/28.611555030000/temperature"
path4="/mnt/1wire/28.8945C4030000/temperature"

subprocess.call(["/opt/owfs/bin/owfs", "--i2c=ALL:ALL", "--allow_other", "/mnt/1wire/"])



# Function to read 1-Wire sensors using OWFS
def get1wiretempreading(path):

    time.sleep(2)
    f = open(path,"r")
    text = f.readlines()
	#f.close()
    return float(text[0]) + 3

while(1): 
    varTempBaseNew = get1wiretempreading(path2)
    if (varTempBaseNew != 88):
        print(varTempBaseNew)
	   
    varTempTopNew = get1wiretempreading(path4)
    if (varTempTopNew != 88):
        print(varTempTopNew)
			
    varTempCollectorNew = get1wiretempreading(path1)
    if (varTempCollectorNew != 88):
        print(varTempCollectorNew)
    time.sleep(1)
