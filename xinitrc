#!/bin/sh
exec setxkbmap "us,ru" ",winkeys" "grp:alt_shift_toggle" &
emerge -1a xterm xclocx twm &
gentoo-pipewire-launcher &
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinir/Xresources
sysmodmap=/etc/X11/xinit/Xmodmap
export QT_QPA_PLATFORMTHEME=qt6ct
if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi
if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi
if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi
if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi


if [ -n "'/etc/X11/chooser.sh'"]; then
command="'/etc/X11/chooser.sh'"
else
 failsafe="yes"
fi

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

if [ -n "$failsafe" ]; then
 exec i3
fi
exec dbus-launch --exit-with-session bspwm
