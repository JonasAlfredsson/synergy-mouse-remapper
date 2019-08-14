# synergy-mouse-remapper

This is a small script, intended to be called via a keyboard shortcut, that will
remap the buttons on the mouse to work correctly when it is shared from a
Windows computer over to Linux via [Synergy (version 1)][1].

For more details to why this was necessary, please read the
[Detailed Information](#detailed-information) section.



# Usage

This script is intended to be run on the Linux computer that connects as a
client to the Synergy server that runs on a Windows computer, and will use the
common `ping` command to determine if is up and running.

By default Windows does not respond to ping, which means we first need to
enable two rules in the Windows firewall.

## Make Windows Respond to Pings

Go to

```
Control Panel -> System and Security -> Windows Defender Firewall
```

and then click the `Advanced settings` option in the the left pane. In
the new windows that opens, click on `Inbound Rules` to the left, and then
find the rules titled `File and Printer Sharing (Echo Request - ICMPv4-In)` in
the long list that appears. Right click both of these and choose `Enable Rule`.
Windows should now be respond to `pings`.

```bash
ping <synergy_server_ip_or_hostname>
```

## Set Server IP

The default IP address, or hostname, of the Synergy sever can be defined on the
first row in the script, but if a local environment variable with the same name
exists it will take precedence over what is written in the script.

## Run

This script is intended to be called via a keyboard shortcut, see the
[next section](#configuring-a-keyboard-shortcut), but can also be run by just
executing the following command:

```bash
bash remapMouseButtons.sh
```

> :warning: When the `xmodmap` command runs you should make sure no modifier
            keys (Ctrl, Shift, etc...) are being pressed, since this might
            mess up the bindings until the command is run again.

The output will then state if the server was up, or not responding, and then
change the mouse buttons accordingly.

## Configuring a Keyboard Shortcut

For the Cinnamon desktop environment it is possible to create a keyboard
shortcut by navigating to the following location:

```
System Settings -> Keybord -> Shortcuts -> Custom Shortcuts
```

and pressing `Add custom shortcut`. In the dialog option that opens I then
added the following:

```
Name:    Toggle Mouse Button Mappings
Command: gnome-terminal -e /full/path/to/remapMouseButtons.sh
```

Before I finally assigned `Ctrl+Alt+C` as the keyboard binding. It should then
be possible to call this remap script whenever by just pressing this key
combination.



# Detailed Information

I am currently using a Windows 10 computer (previously Win7), as my Synergy
server, and share the mouse and keyboard from this over to my Debian Linux
computer. The peripherals in question work flawlessly when plugged directly in
to either of the machines, but what I noticed was that the buttons on my mouse
did not work as intended when it was shared to a Linux computer via Synergy on
Windows.

The mouse I am using is a Logitech G500 ([PDF Manual][3]), which has a total of
12 (electric) buttons that I can see:

1. Left Mouse Button
2. Mouse Wheel Click
3. Right Mouse Button
4. Mouse Wheel Up
5. Mouse Wheel Down
6. Mouse Wheel Left Tilt
7. Mouse Wheel Right Tilt
8. Thumb Backwards Button
9. Thumb Forwards Button
10. Thumb Middle Button
11. Increase DPI
12. Decrease DPI

Out of these the first 10 are identifiable by the `xmodmap -pp` command, and
exactly which button that corresponds to what number can be analyzed by playing
around with the program `xev`, which is very verbose when it comes to mouse
events.

With [this thread][2] on GitHub as a starting point I used the `xev` program to
identify that, when the mouse is shared from Windows to Linux, the buttons 6 & 7
trade places with 8 & 9. So the button list from Synergy is:

6. Thumb Backwards Button
7. Thumb Forwards Button
8. Mouse Wheel Left Tilt
9. Mouse Wheel Right Tilt

which does not correspond to the ordering expected by Linux. It is stated in
the GitHub thread that it should be possible to remap these buttons in the
`synergy.conf`, but just like the author I found this a bit unreliable.

What have worked very reliably for me this whole time was to use the `xmodmap`
program to remap the mouse buttons instead.

```bash
xmodmap -e "pointer = 1 2 3 4 5 8 9 6 7"
          # position  1 2 3 4 5 6 7 8 9
```

This simple command will just remap the 6th button to mean the 8th, and vice
versa. So when I press "Thumb Backwards Button" on Windows, Synergy will send
over button "position code" 8 (originally Mouse Wheel Left Tilt), but `xmodmap`
will now interpret this as position code 6 (Thumb Backwards Button) instead
and thus work as expected.

The only issue is that if you plug in another mouse into the Linux computer
directly it will be the wrong order again. This is the reason to why I built
this toggle script which allows for fast and easy switching.



[1]: https://symless.com/synergy
[2]: https://github.com/symless/synergy-core/issues/58
[3]: https://www.logitech.com/assets/50635/3/gaming-mouse-g500-user-guide.pdf
