lappend auto_path ./lib

package require Tcl 8.5
package require Tk 8.5

package require ff-p-navi
source style.tcl

namespace eval gui {
    grid columnconfigure . 0 -weight 1
    grid rowconfigure . 0 -weight 1
    ttk::frame .cmdline -padding 2
    ttk::label .cmdline.label -text ">"
    ttk::entry .cmdline.entry 
    grid .cmdline.label .cmdline.entry 
    grid configure .cmdline.label -sticky nsw
    grid configure .cmdline.entry -sticky nsew
    grid columnconfigure .cmdline 1 -weight 1
    
    ttk::notebook .tabs

    ttk::frame .tabs.navi

    .tabs add .tabs.navi -text "Navigation" -sticky nswe

    navi::init .tabs.navi

    grid .tabs -sticky nsew
    grid .cmdline -sticky esw
}
