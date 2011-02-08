lappend auto_path ./lib

package require Tcl 8.5
package require Tk 8.5

package require ff-p-navi
source style.tcl

namespace eval gui {

    ttk::frame .cmdline
    ttk::entry .cmdline.entry 
    ttk::button .cmdline.reset -text "Reset"
    grid .cmdline.entry .cmdline.reset
    
    ttk::notebook .tabs

    ttk::frame .tabs.navi

    .tabs add .tabs.navi -text "Navigation"

    navi::init .tabs.navi

    grid .tabs -sticky new
    grid .cmdline -sticky esw
}
