# navi.tcl
# файл содержит навигационные процедуры для пользователя
# предоставляется минимум необходимой информации и кода
# остальное будет сделано как программа бортового компьютера

package require Tcl 8.5
package require ff-object

package provide ff-navi 0.0

namespace eval navi {
    namespace export position velocity angle
    
    proc position {shipname} {
	global objects
	return [dict get $objects($shipname) position]
    }

    proc velocity {shipname} {
	global objects
	set s [dict get $objects($shipname) speed]
	set x [lindex $s 0]
	set y [lindex $s 1]
	set abs_speed [expr sqrt($x**2+$y**2)]
	if { $x != 0 } {
	    set angle [expr atan([lindex $s 1]/[lindex $s 0])]
	    if {$x < 0} {
		set angle [expr 3.14159+$angle]
	    }
	} elseif {y>0} {
	    set angle [expr 3.14159/2]
	} else {
	    set angle [expr 3*3.14159/2]
	}
	if {$angle < 0} {
	    set angle [expr $angle+3.14159]
	}
	if {$angle > 2*3.14159} {
	    set angle [expr $angle-2*3.14159]
	}
	#return [list $abs_speed $angle]
	return [format "%.3f %.1f" $abs_speed [expr $angle/3.14159*180]]
    }

# возвращает угол относительно "неподвижных звёзд"
    proc angle {shipname} {
	global objects
	return [format "%.1f" [dict get $objects($shipname) angle]]
    }
}
