namespace eval img {}

set ::img::background [image create photo -file background.ppm]
ttk::style element create Frame.border image $::img::background -border 4 -sticky nsew 
ttk::style layout TFrame { Frame.border -sticky nsew }

ttk::style configure TLabel -foreground green -background black
ttk::style configure TEntry -foreground green -fieldbackground black -relief none
ttk::style configure TNotebook -borderwidth 0
ttk::style configure TCanvas -background black

ttk::style configure Treeview -fieldbackground black -borderwidth 0
ttk::style configure Treeview.Row -background black 
ttk::style configure Treeview.Item  -foreground green
ttk::style configure Treeview.Cell  -foreground green
ttk::style configure Treeview.Heading -foreground green  -relief flat
ttk::style map Treeview.Heading -background {active darkgreen !active black} 
