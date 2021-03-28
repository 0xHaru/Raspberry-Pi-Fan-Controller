import os

import matplotlib.dates
import matplotlib.pyplot as plt
from dt import dt

plt.rcParams["font.size"] = 18
PATH = os.path.dirname(__file__) + "/"

with open(f"{PATH}timestamp.log", "r") as f:
    timestamp_list = [dt.strptime(x.strip(), "%d/%m/%Y %H:%M:%S") for x in f]

with open(f"{PATH}cpu.log", "r") as f:
    cpu_list = [float(x) for x in f]

with open(f"{PATH}ram.log", "r") as f:
    ram_list = [float(x) for x in f]

timestamp_printable = [dt.strftime(x, "%d/%m/%Y %H:%M:%S") for x in timestamp_list]

print(f"TIME_LIST:\n{timestamp_printable}\n")
print(f"CPU_LIST:\n{cpu_list}\n")
print(f"RAM_LIST:\n{ram_list}\n")

figure = plt.figure()
plt.subplots_adjust(left=0.125, bottom=0.1, right=0.9, top=0.9, wspace=0.2, hspace=0.5)
figure.set_size_inches(18.5, 10.5)
axes_1 = plt.subplot(211)  # 211 => nrows=2, ncols=1, plot_number=1
axes_2 = plt.subplot(212)  # 212 => nrows=2, ncols=1, plot_number=2

axes_1.set_title("CPU")
axes_1.set_xlabel("Time")
axes_1.set_ylabel("Usage")

axes_2.set_title("RAM")
axes_2.set_xlabel("Time")
axes_2.set_ylabel("Usage")

axes_1.xaxis.labelpad = 20
axes_1.yaxis.labelpad = 20
axes_2.xaxis.labelpad = 20
axes_2.yaxis.labelpad = 20

formatter = matplotlib.dates.DateFormatter("%H:%M:%S")

axes_1.xaxis.set_major_formatter(formatter)
axes_2.xaxis.set_major_formatter(formatter)

axes_1.plot(timestamp_list, cpu_list)
axes_2.plot(timestamp_list, ram_list)

plt.savefig(f"{PATH}data.png", format="png", dpi=300)
