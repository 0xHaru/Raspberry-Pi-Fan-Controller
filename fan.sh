#!/usr/bin/env bash

GPIO_PATH="/sys/class/gpio"
CONFIG_FILE="$HOME/.config/fan/config.conf"

threshold=45
pin=12
sleep_interval=5

# Ctrl+c handler
trap shutdown INT

# Invoked on Ctrl+c (SIGINT)
shutdown() {
    printf "0" >"$GPIO_PATH/gpio$pin/value"
    exit 0
}

usage() {
    printf "usage: fan [-h] [-t THRESH] [-p PIN]\n"
    echo "-t THRESH, --thresh THRESH    set the threshold temperature\n"
    echo "-p PIN,    --pin PIN          set the GPIO pin\n"
    echo "-s SLEEP,  --sleep SLEEP      set the sleep interval\n"
}

[ -f "$CONFIG_FILE" ] && {
    threshold=$(sed -n "s/thresh=//p" "$CONFIG_FILE")
    pin=$(sed -n "s/pin=//p" "$CONFIG_FILE")
    sleep_interval=$(sed -n "s/sleep=//p" "$CONFIG_FILE")
}

while [ "$#" -gt 0 ]; do
    key="$1"

    case "$key" in
    -h | --help)
        usage
        exit 0
        ;;
    -t | --thresh)
        threshold="$2"
        shift
        ;;
    -p | --pin)
        pin="$2"
        shift
        ;;
    -s | --sleep)
        sleep_interval="$2"
        shift
        ;;
    *)
        printf "Unknown parameter \"%s\"\n" "$key"
        usage
        exit 1
        ;;
    esac
    shift
done

# Export pin if not already exported
if [ ! -e "$GPIO_PATH/gpio$pin" ]; then
    printf "%s" "$pin" >"$GPIO_PATH/export"
fi

# Set pin as an output
printf "out" >"$GPIO_PATH/gpio$pin/direction"
printf "GPIO pin: %s\n" "$pin"

flag=0

while true; do
    temp=$(vcgencmd measure_temp)
    temp=${temp#*=}
    temp=${temp%.*}

    if [ "$flag" -eq "0" ] && [ "$temp" -ge "$threshold" ]; then
        printf "%(%d-%b-%Y %H:%M:%S)T - ON\n" -1
        printf "1" >"$GPIO_PATH/gpio$pin/value"
        flag=1
    elif [ "$flag" -eq "1" ] && [ "$temp" -lt "$threshold" ]; then
        printf "%(%d-%b-%Y %H:%M:%S)T - OFF\n" -1
        printf "0" >"$GPIO_PATH/gpio$pin/value"
        flag=0
    fi

    sleep "$sleep_interval"
done
