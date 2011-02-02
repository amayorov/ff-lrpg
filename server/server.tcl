lappend ::auto_path .

package require ff-object
package require ff-user
package require ff-navi

namespace eval test {
    proc a {} {
	return a
    }
    proc echo {a} {
	return $a
    }
}

user allow ::test::echo shipname {$ship}
# Следующие строчки работают не по имени корабля, а по значению
user allow ::ship::engines {} {$objects($ship)}
user allow ::ship::tanks {} {$objects($ship)}


user allow ::ship::throttle ::throttle {$ship}
user allow ::ship::steer ::steer {$ship}
user allow ::object::inventory::list ::inv {$ship}

user allow ::navi::position {} {$ship}
user allow ::navi::velocity {} {$ship}
user allow ::navi::angle {} {$ship}

user allow ::user::unknown ::unknown {$ship}


namespace eval server {
    proc listen {sd host port} {
	variable connections
	puts "Connected from $host:$port"
        fconfigure $sd -buffering line
	fileevent $sd readable [list ::server::chat $sd]
    }

    proc chat {sd} {
	variable connections
	if {[eof $sd] || [catch {gets $sd packet}]} {
	    close $sd
	    puts "Connection with $connections($sd) closed"
	    unset connections($sd)
	    return
	}
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
	puts "$obj: Pos {[dict get $objects($obj) position]} Sp {[dict get $objects($obj) speed]}"
	tick $obj 1
    }
    puts {}
    after 1000 {set t 0}
    vwait t
}
