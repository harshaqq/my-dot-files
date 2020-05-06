xset s on
xset s 120
exec xss-lock slock &
xrdb -load ~/.Xresources
dbus-launch --exit-with-session emacs --daemon -f exwm-enable
exec emacsclient -c


