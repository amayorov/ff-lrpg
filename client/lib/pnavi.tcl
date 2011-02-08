package require Tcl 8.5
package require Tk 8.5

package require ff-network

package provide ff-p-navi 0.0

namespace eval gui {
    namespace eval navi {
	proc init {parent} {
	    variable p
	    set p $parent
	    set copts {}
	    foreach opt {background relief borderwidth} {
		lappend copts -$opt [::ttk::style lookup TCanvas -$opt]
	    }
	    ttk::frame $p.left 
	    ttk::frame $p.right -width 100m
	    ttk::frame $p.cmdline
	    ttk::frame $p.left.radar 
	    canvas $p.left.radar.screen -width 100m -height 100m {*}$copts
	    $p.left.radar.screen create oval 0 0 100m 100m -outline black
	    ::ttk::frame $p.left.b -height 30m
	    
	    pack $p.left.radar.screen
	    
	    grid $p.left.radar
	    grid $p.left.b -sticky esw

	    grid $p.left $p.right -sticky ns
	    grid $p.cmdline -
	}
    }
}
