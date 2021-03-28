import os

PATH = os.path.dirname(__file__) + "/"

with open(f"{PATH}cpu.log", "r") as f:
    cpu_list = [float(x) for x in f]

with open(f"{PATH}ram.log", "r") as f:
    ram_list = [float(x) for x in f]

cpu_avg = sum(cpu_list) / len(cpu_list)
ram_avg = sum(ram_list) / len(ram_list)

print(f"CPU:\n{cpu_list}\n")
print(f"RAM:\n{ram_list}\n")

print(f"CPU AVG: {cpu_avg}\n")
print(f"RAM AVG: {ram_avg}\n")

with open(f"{PATH}average.txt", "a") as f:
    f.write(f"CPU AVG: {cpu_avg}\n")
    f.write(f"RAM AVG: {ram_avg}")
