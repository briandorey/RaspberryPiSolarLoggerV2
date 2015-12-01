import RPi.GPIO as GPIO

GPIO.setmode(GPIO.BCM)

GPIO.setup(19, GPIO.IN, pull_up_down = GPIO.PUD_DOWN)


while True:

    if(GPIO.input(19) ==1):

        print("Pump Running")

    if(GPIO.input(19) == 0):

        print("Pump Off")

GPIO.cleanup()
