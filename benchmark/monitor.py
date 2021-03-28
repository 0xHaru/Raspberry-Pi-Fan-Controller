import os
from datetime import datetime
from time import sleep

import psutil

PATH = os.path.dirname(__file__) + "/"

cpu_log = open(f"{PATH}cpu.log", "a")
ram_log = open(f"{PATH}ram.log", "a")
timestamp_log = open(f"{PATH}timestamps.log", "a")

for i in range(0, 300):
    timestamp = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    cpu_usage = psutil.cpu_percent()
    ram_usage = psutil.virtual_memory().percent

    timestamp_log.write(str(timestamp) + "\n")
    cpu_log.write(str(cpu_usage) + "\n")
    ram_log.write(str(ram_usage) + "\n")

    print(f"{timestamp}  |  CPU: {cpu_usage}  |  RAM: {ram_usage}")

    sleep(1)

cpu_log.close()
ram_log.close()
timestamp_log.close()
