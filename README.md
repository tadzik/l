Perl modules needed:
* Gtk2
* XML::Simple
* File::Slurp

Instructions:
- Adjust menu.xml for your needs
- Move it to ~/.config/menu.xml
- Run the app, it will write its PID to ~/.config/l.pid
- You can now bring it up with kill -USR1 `cat ~/.config/l.pid` or something
