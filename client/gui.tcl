lappend auto_path ./lib

package require Tcl 8.5
package require Tk 8.5

package require ff-p-navi
source style.tcl

namespace eval event {}

namespace eval gui {
    
    proc enter_command {} {
	set cmd [.cmdline.entry get]
	.cmdlog.text insert end "\n" {} $cmd command "\n"
	set result [net send $cmd]
	.cmdlog.text insert end $result result 
	.cmdlog.text yview end
	.cmdline.entry delete 0 end
    }

    proc update_radar_trig {args} {
	navi::update_radar
	after 1000 set ::event::radar 1
    }

    proc settab {tabname} {
	set current [pack slaves .tabs]
	if {! ($current eq {} )} {
	    pack forget $current
	}
	pack $tabname -fill both
    }

    grid columnconfigure . 0 -weight 1
    grid rowconfigure . 0 -weight 1


    ttk::frame .cmdline -padding 2
    ttk::label .cmdline.label -text ">"
    ttk::entry .cmdline.entry 
    grid .cmdline.label .cmdline.entry 

    ttk::frame .cmdlog -padding 2
    text .cmdlog.text -background black -foreground green -height 3 -takefocus 0 -yscrollcommand [list .cmdlog.sbar set]
    .cmdlog.text tag configure result -foreground gray 
    ttk::scrollbar .cmdlog.sbar -orient vertical -command [list .cmdlog.text yview]
    grid .cmdlog.text .cmdlog.sbar -sticky nsew
    grid columnconfigure .cmdlog 0 -weight 1

    grid configure .cmdline.label -sticky nsw
    grid configure .cmdline.entry -sticky nsew
    grid columnconfigure .cmdline 1 -weight 1
    
    ttk::frame .tabs

    ttk::frame .tabs.navi
    ttk::frame .tabs.inv
    ttk::frame .tabs.target

    #pack .tabs.navi -fill both
    gui::settab .tabs.navi

    #.tabs add .tabs.navi -text "Navigation" -sticky nswe

    navi::init .tabs.navi

    grid .tabs -sticky nsew
    grid .cmdlog -sticky nesw
    grid .cmdline -sticky esw
    
    bind .cmdline.entry <KeyPress-Return> {gui::enter_command} 

    # Да здравствует быдлокод!!! Если быстро вернуть отобранный фокус, то
    # никто ничего не заметит
    bind .cmdline.entry <FocusOut> { focus .cmdline.entry }

    trace add variable ::event::radar write ::gui::update_radar_trig
    
    focus .cmdline.entry
#    grab .cmdline.entry
}

net connect 127.0.0.1
set ::event::radar 1
