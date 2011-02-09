package require Tcl 8.5
package require Tk 8.5

package require ff-network

package provide ff-p-navi 0.0

namespace eval gui {
    namespace eval navi {
	set zoom 1 ;# 1mm = 1 km
	proc init {parent} {
	    variable p
	    set p $parent
	    set copts {}
	    foreach opt {background} {
		lappend copts -$opt [::ttk::style lookup TCanvas -$opt]
	    }
	    ttk::frame $p.left 
	    ttk::frame $p.right  -width 100m
	    ttk::frame $p.left.radar -padding 2

	    canvas $p.left.radar.screen -width 100m -height 100m {*}$copts
	    $p.left.radar.screen create oval 0 0 100m 100m -outline green
	    ::ttk::frame $p.left.b -height 30m
	    
	    grid $p.left.radar.screen -sticky nsew
	    grid columnconfigure $p.left.radar 0 -weight 1
	    grid rowconfigure $p.left.radar 0 -weight 1
	    
	    grid $p.left.radar -sticky nsew
	    grid $p.left.b -sticky nesw
	    grid columnconfigure $p.left 0 -weight 1
	    grid rowconfigure $p.left 0 -weight 1

	    grid $p.left $p.right -sticky nsew
	    grid columnconfigure $p 0 -weight 1
	    grid columnconfigure $p 1 -weight 1
	    grid rowconfigure $p 0 -weight 1
	}
    }
}
