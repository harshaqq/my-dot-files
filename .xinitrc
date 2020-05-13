xset s off
xset s 120
exec xss-lock slock &
xrdb -load ~/.Xresources
#dbus-launch --exit-with-session emacs -f exwm-enable
#exec emacsclient -c
exec dbus-launch --exit-with-session emacs

