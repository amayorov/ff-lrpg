lappend ::auto_path .

package require ff-object
package require ff-user
package require ff-navi
package require Tk 8.5

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
user allow ::navi::aspeed {} {$ship}
user allow ::navi::radar {} {$ship}

user allow ::user::unknown ::unknown {$ship}

user allow ::user::auto ::auto {$ship}

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
	    user init $ship
	} elseif { [info exists connections($sd)] } {
	    set ship $connections($sd)
	    set result [user run $ship $dat]
	    puts $sd [list $id $result]
	}
    }

    socket -server ::server::listen 9999

}

proc draw_ship {widget name} {
    set offset(x) [expr [winfo width $widget]/2]
    set offset(y) [expr [winfo height $widget]/2]
    set scale 1.
    set sinfo $::objects($name)
    set a [dict get $sinfo angle]
    set pos [dict get $sinfo position]
    set points { -10 -4 10 0 -10 4 -4 0}
    set rotated_points {}
    set x0 [expr $offset(x)+[lindex $pos 0]*$scale]
    set y0 [expr $offset(y)-[lindex $pos 1]*$scale]
    foreach {x y} $points {
	lappend rotated_points [expr $x*cos($a)-$y*sin($a)+$x0] [expr $y0-($x*sin($a)+$y*cos($a))]
    }
    if {[$widget gettags $name] != {}} {
	$widget coords $name $rotated_points
    } else {
	$widget create polygon $rotated_points -tags $name -fill black -activefill red
    }
}

source test.tcl
set dt 100
set t 0
set scale 10

canvas .c -width 100m -height 100m
frame .f 
label .f.name 
label .f.value
pack .c
grid .f.name .f.value
pack .f
.c create oval 1 1 100m 100m -outline black
.c create line 50m 0 50m 100m -fill grey
.c create line 0 50m 100m 50m -fill grey
set selected {}

set log [open "log.txt" "w" ]
while yes {
    foreach obj [array names objects] {
#	puts "$obj: Pos {[dict get $objects($obj) position]} Sp {[dict get $objects($obj) speed]}"

	puts $log [concat [dict get $objects($obj) position] [dict get $objects($obj) speed]]
	flush $log
	draw_ship .c $obj
	do_physic $obj [expr double($dt)/1000]
	if {[is $objects($obj) ship]} {
	    user do_autos $obj
	}
    }
    
    foreach sh [.c gettags current] {
	if {$sh != "current"} {
	    set selected $sh
	    .f.name configure -text $selected
	}
	break
    }
    if {$selected != {} } {
	.f.value configure -text [format "%.3f %.3f" {*}[dict get $objects($selected) position]]
    }
    after $dt {set t [expr 1.0*$t+$dt]}
    vwait t
}
