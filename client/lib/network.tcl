package require Tcl 8.5
package provide ff-network 0.0

namespace eval net {
    namespace export connect disconnect send
    variable sd

    proc connect {addr {port 9999}} {
	variable sd
	set sd [socket $addr $port]
	fconfigure $sd -buffering line
	puts $sd {auth {Destiny foobar}}
    }

    proc send {cmd} {
	puts $sd [list gui $cmd]
	set ans [gets $sd]
	return [lindex $ans 1]
    }

    proc disconnect {} {
	variable sd
	close $sd
    }
}
