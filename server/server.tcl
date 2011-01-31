source object.tcl
source user.tcl

namespace eval server {
    proc listen {sd host port} {
	puts "Connected from $host:$port"
	if {![fblocked  $sd]} {
	    puts [read $sd]
	}
    }

    socket -server ::server::listen 9999

}

vwait forever
