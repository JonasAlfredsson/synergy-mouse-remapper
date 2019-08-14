#!/bin/bash
# A script that pings a Synergy server and changes the button layout of the
# mouse to map them correctly depending on which system is the host of the
# peripherals.
: ${SYNERGY_SERVER:="192.168.10.11"}

if `ping $SYNERGY_SERVER -c 1 -W 1 | grep -q "100%"`
then
    # Map mouse buttons to behave correctly under Linux when not using Synergy.
    echo "The Synergy server at '$SYNERGY_SERVER' was unreachable."
    echo "Setting the buttons to standard Linux."
    xmodmap -e "pointer = 1 2 3 4 5 6 7 8 9"
else
    # Map mouse buttons to behave correctly under Linux when using Synergy from
    # a Windows computer.
    echo "The Synergy server at '$SYNERGY_SERVER' responded."

    # The `xmodmap` command will behave very strangely if any modifier keys
    # (CTRL,SHIFT, etc...) are being pressed while it executes.
    # A short sleep is therefore introduced here to allow the user to release
    # any of those keys if this script is being called by a keyboard shortcut.
    sleep 1

    echo "Setting buttons to Windows mode."
    xmodmap -e "pointer = 1 2 3 4 5 8 9 6 7"
fi

# Allow the user to see that the script has executed.
sleep 2

exit 0
