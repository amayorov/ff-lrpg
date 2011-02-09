lappend auto_path ./lib

package require Tcl 8.5
package require Tk 8.5

package require ff-p-navi
source style.tcl

namespace eval gui {
    
    proc enter_command {} {
	set cmd [.cmdline.entry get]
	.cmdlog.text insert end $cmd command "\n"
	set result [net send $cmd]
	.cmdlog.text insert end $result result "\n"
	.cmdline.entry delete 0 end
    }

    grid columnconfigure . 0 -weight 1
    grid rowconfigure . 0 -weight 1
    ttk::frame .cmdline -padding 2
    ttk::label .cmdline.label -text ">"
    ttk::entry .cmdline.entry 
    grid .cmdline.label .cmdline.entry 

    ttk::frame .cmdlog -padding 2
    text .cmdlog.text -background black -foreground green -height 3 -takefocus 0
    .cmdlog.text tag configure result -foreground gray

    grid .cmdlog.text -sticky nsew
    grid columnconfigure .cmdlog 0 -weight 1

    grid configure .cmdline.label -sticky nsw
    grid configure .cmdline.entry -sticky nsew
    grid columnconfigure .cmdline 1 -weight 1
    
    ttk::notebook .tabs

    ttk::frame .tabs.navi

    .tabs add .tabs.navi -text "Navigation" -sticky nswe

    navi::init .tabs.navi

    grid .tabs -sticky nsew
    grid .cmdlog -sticky nesw
    grid .cmdline -sticky esw
    
    bind .cmdline.entry <KeyPress-Return> {gui::enter_command} 
}

net connect 127.0.0.1
