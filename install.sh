#!/bin/sh

# This script should be run via wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/0xharu/raspberry-pi-fan-controller/master/install.sh)"

CONFIG_DIR="$HOME/.config/fan"
BIN_DIR="$HOME/.local/bin"

# Colors
NC="\033[0m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
RED="\033[1;31m"
MAGENTA="\033[1;35m"

check_reply() {
    [ "$1" = "y" ] || [ "$1" = "Y" ] || [ "$1" = "yes" ] || [ "$1" = "Yes" ] || [ "$1" = "YES" ]
}

# Add a cronjob to $USER crontab
cronjob() {
    [ "$1" = "sh" ] && {
        sudo su <<HERE
echo "@reboot sudo $BIN_DIR/$2 >/dev/null 2>&1 || touch $HOME/Desktop/AUTOSTART_FAILED" >> /var/spool/cron/crontabs/$USER
HERE
    } || {
        sudo su <<HERE
echo "@reboot $BIN_DIR/$2 >/dev/null 2>&1 || touch $HOME/Desktop/AUTOSTART_FAILED" >> /var/spool/cron/crontabs/$USER
HERE
    }
}

# Create ~/.local/bin
[ ! -d "$BIN_DIR" ] && mkdir "$BIN_DIR"

# Menu
printf "Install:\n\t1) Python script\n\t2) Bash script\n\t3) Both\n\nEnter you choice: "
read -r REPLY

case "$REPLY" in
1)
    [ ! -f "$BIN_DIR/fan" ] && {
        wget -qO "$BIN_DIR/fan" https://raw.githubusercontent.com/0xharu/raspberry-pi-fan-controller/master/fan.py
        chmod +x "$BIN_DIR/fan"
        choice=1
        printf "\n${GREEN}%s/fan${NC} has been successfully created.\n" "$BIN_DIR"
    } || {
        printf "\n${RED}%s/fan${NC} already exists.\n" "$BIN_DIR"
        exit 1
    }
    ;;
2)
    [ ! -f "$BIN_DIR/fan" ] && {
        wget -qO "$BIN_DIR/fan" https://raw.githubusercontent.com/0xharu/raspberry-pi-fan-controller/master/fan.sh
        chmod +x "$BIN_DIR/fan"
        choice=2
        printf "\n${GREEN}%s/fan${NC} has been successfully created.\n" "$BIN_DIR"
    } || {
        printf "\n${RED}%s/fan${NC} already exists.\n" "$BIN_DIR"
        exit 1
    }
    ;;

3)
    [ ! -f "$BIN_DIR/fan" ] && [ ! -f "$BIN_DIR/fan-py" ] && [ ! -f "$BIN_DIR/fan-sh" ] && {
        wget -qO "$BIN_DIR/fan-py" https://raw.githubusercontent.com/0xharu/raspberry-pi-fan-controller/master/fan.py
        wget -qO "$BIN_DIR/fan-sh" https://raw.githubusercontent.com/0xharu/raspberry-pi-fan-controller/master/fan.sh

        chmod +x "$BIN_DIR/fan-py"
        chmod +x "$BIN_DIR/fan-sh"

        choice=3
        printf "\n${GREEN}%s/fan-py${NC} has been successfully created.\n\
${GREEN}%s/fan-sh${NC} has been successfully created.\n" "$BIN_DIR" "$BIN_DIR"
    } || {
        printf "\n${RED}%s/fan${NC} or ${RED}%s/fan-py${NC} or ${RED}%s/fan-sh${NC} already exists.\n" "$BIN_DIR" "$BIN_DIR" "$BIN_DIR"
        exit 1
    }
    ;;

*)
    printf "\nUnknown option: \"%s\"\n" "$REPLY"
    exit 1
    ;;
esac

# Create ~/.config/fan/config.conf
[ ! -d "$CONFIG_DIR" ] && mkdir "$CONFIG_DIR"

[ ! -f "$CONFIG_DIR/config.conf" ] && touch "$CONFIG_DIR/config.conf" &&
    printf "[settings]\nthresh=45\npin=12\nsleep=5" >"$CONFIG_DIR/config.conf" &&
    printf "${GREEN}%s/config.conf${NC} has been successfully created.\n" "$CONFIG_DIR"

# Autostart
printf "\nTo autostart a script the following line must be added to /var/spool/cron/crontabs/%s:\
\n\n${MAGENTA}@reboot %s/.local/bin/fan${NC}\
\n\nTo do that the \"sudo\" and \"sudo su\" commands have to be used.\
\n\nDo you want to autostart the script? (y/N) " "$USER" "$HOME"
read -r REPLY

if check_reply "$REPLY"; then
    sudo grep "fan" "/var/spool/cron/crontabs/$USER" && printf "Skipping, the cronjob already exists." || {
        log
        case "$choice" in
        1)
            cronjob "py" "fan"
            printf "\nCronjob successfully created.\n"
            ;;
        2)
            cronjob "sh" "fan"
            printf "\nCronjob successfully created.\n"
            ;;
        3)
            printf "\nWhich script do you want to autostart?\n1) Python\n2) Bash\n\nEnter your choice: "
            read -r REPLY

            case "$REPLY" in
            1)
                cronjob "py" "fan-py"
                printf "\nCronjob successfully created.\n"
                ;;
            2)
                cronjob "sh" "fan-sh"
                printf "\nCronjob successfully created.\n"
                ;;
            *)
                printf "\nUnknown option: \"%s\"\n" "$REPLY"
                exit 1
                ;;
            esac
            ;;
        *)
            printf "\nUnknown option: \"%s\"\n" "$REPLY"
            exit 1
            ;;
        esac
    }
fi

# Brief explanation
printf "\nIf you selected 1) or 2) you can run the script with \"fan\".\n\
If you selected 3) you can run the script with \"fan-py\" or \"fan-sh\".\n\
\nThe config file is located here: ${GREEN}%s/config.conf${NC}\n\
The script is located here: ${GREEN}%s${NC}\n\
\nUse the -h flag to learn how to use the script.\n" "$CONFIG_DIR" "$BIN_DIR"

# Tips
printf "\n${YELLOW}TIPS:${NC}\n\n\
- If you want to run the script as a daemon add this alias to your .bashrc, .zshrc, etc.:\
\n\n${MAGENTA}  alias fan-d=\"nohup fan >/dev/null 2>&1 &\"${NC}\n\n\
  Make sure to change \"fan\" to \"fan-py\" or \"fan-sh\" if you installed both scripts.\n\n"

# Check $PATH
echo "$PATH" | grep -q "$HOME/.local/bin" ||
    printf "${BLUE}IMPORTANT:${NC}\nAdd this line to your .bashrc, .zshrc, etc.:\
    \n\n${MAGENTA}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}\n\n"
