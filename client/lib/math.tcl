package require Tcl 8.5

package provide ff-math 0.0

namespace eval tcl::mathfunc {
    proc pi {} {
	return 3.1415926535897932
    }
    proc todeg {x} {
	set y [expr {(-1.)*round($x/pi()*180)}]
	return [expr {$y>0?$y:360+($y)}]
    }
}
