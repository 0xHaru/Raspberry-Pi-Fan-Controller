#!/bin/sh

# This script should be run via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/0xharu/raspberry-pi-fan-controller/master/uninstall.sh)"

CONFIG_DIR="$HOME/.config/fan"
BIN_DIR="$HOME/.local/bin"

# Colors
NC="\033[0m"
YELLOW="\033[1;33m"

check_reply() {
    [ "$1" = "n" ] || [ "$1" = "N" ] || [ "$1" = "no" ] || [ "$1" = "No" ] || [ "$1" = "NO" ]
}

remove_cronjob() {
    sudo su <<HERE
grep -q "/Desktop/AUTOSTART_FAILED" "/var/spool/cron/crontabs/$USER" &&
sed -i "/\/Desktop\/AUTOSTART_FAILED/d" "/var/spool/cron/crontabs/$USER"
HERE
}

printf "Do you want to uninstall the fan controller? (Y/n) "
read -r REPLY

check_reply "$REPLY" && exit 0

[ -f "$BIN_DIR/fan" ] && rm "$BIN_DIR/fan" &&
    printf "\n${YELLOW}%s/fan${NC} successfully removed\n" "$BIN_DIR" || {

    [ -f "$BIN_DIR/fan-py" ] && rm "$BIN_DIR/fan-py" && printf "\n${YELLOW}%s/fan-py${NC} successfully removed." "$BIN_DIR"
    [ -f "$BIN_DIR/fan-sh" ] && rm "$BIN_DIR/fan-sh" && printf "\n${YELLOW}%s/fan-sh${NC} successfully removed.\n" "$BIN_DIR"
}

[ -d "$CONFIG_DIR" ] && rm -r "$CONFIG_DIR" && printf "\n${YELLOW}%s${NC} successfully removed.\n" "$CONFIG_DIR"

printf "\nTo do the following operation the \"sudo\" and \"sudo su\" commands have to be used.
Do you want to remove the cronjob? (y\N) "

read -r REPLY

[ "$REPLY" = "y" ] && remove_cronjob && printf "\nCronjob successfully removed.\n\n" || printf "\nSkipping.\n\n"
