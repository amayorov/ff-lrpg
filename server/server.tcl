source object.tcl
source user.tcl

namespace eval test {
    proc a {} {
	return a
    }
    proc echo {a} {
	return $a
    }
}

user allow ::test::echo shipname {$ship}
user allow ::ship::engines {} {$ship}
user allow ::ship::tanks {} {$ship}
user allow ::ship::throttle ::throttle {$ship}
user allow ::ship::turn ::turn {$ship}
user allow ::object::inventory::list ::inv {$ship}


namespace eval server {
    proc listen {sd host port} {
	variable connections
	puts "Connected from $host:$port"
        fconfigure $sd -buffering line
	fileevent $sd readable [list ::server::chat $sd]
    }

    proc chat {sd} {
	variable connections
	set packet [gets $sd]
	if {[llength $packet]!= 2} {return}
	set id [lindex $packet 0]
	set dat [lindex $packet 1]
	if {$id == "auth" && [llength $dat] == 2} {
	    set ship [lindex $dat 0]
	    set secret [lindex $dat 1]
	    set connections($sd) $ship
	    puts "Authenticated $ship"
	} elseif { [info exists connections($sd)] } {
	    set ship $connections($sd)
	    set result [user run $ship $dat]
	    puts $sd [list $id $result]
	}
	
    }

    socket -server ::server::listen 9999

}

source test.tcl

while yes {
    foreach obj [array names objects] {
	puts "Speed [dict get $objects($obj) speed]"
	puts "Coords [dict get $objects($obj) position]"
	tick $obj 1
    }
    puts {}
    after 1000 {set t 0}
    vwait t
}
#vwait forever