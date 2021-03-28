#!/usr/bin/env python3

import argparse
import configparser
import os
from datetime import datetime
from time import sleep

from gpiozero import OutputDevice

CONFIG_FILE = os.path.expanduser("~/.config/fan/config.conf")

threshold = 45
pin = 12
sleep_interval = 5

if os.path.exists(CONFIG_FILE):
    config = configparser.ConfigParser()
    config.read(CONFIG_FILE)

    threshold = int(config["settings"]["thresh"])
    pin = int(config["settings"]["pin"])
    sleep_interval = int(config["settings"]["sleep"])

parser = argparse.ArgumentParser(description="Temperature based RPI fan controller.")
parser.add_argument(
    "-t", "--thresh", type=int, help="set the threshold temperature", nargs=1
)
parser.add_argument("-p", "--pin", type=int, help="set the GPIO pin", nargs=1)
parser.add_argument("-s", "--sleep", type=int, help="set the sleep interval", nargs=1)

args = parser.parse_args()

if args:
    if args.thresh:
        threshold = int(args.thresh)

    if args.pin:
        pin = int(args.pin)

    if args.sleep:
        sleep_interval = int(args.sleep)

fan = OutputDevice(pin)
print(f"GPIO pin: {pin}")

flag = 0

while True:
    temp_data = os.popen("vcgencmd measure_temp").readline()
    temperature = int(temp_data[5:-5])

    if not flag and temperature >= threshold:
        fan.on()
        flag = 1
        print(datetime.now().strftime("%d-%b-%Y %H:%M:%S") + " - ON")
    elif flag and temperature < threshold:
        fan.off()
        flag = 0
        print(datetime.now().strftime("%d-%b-%Y %H:%M:%S") + " - OFF")

    sleep(sleep_interval)
