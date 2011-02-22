package require Tcl 8.5
package require Tk 8.5

package require ff-client-network
package require ff-math

package provide ff-p-inv 0.0

namespace eval gui {
    namespace eval inv {
	proc init {parent} {
	    variable p
	    set p $parent
	    
	    set copts {}
	    foreach opt {background} {
		lappend copts -$opt [::ttk::style lookup TCanvas -$opt]
	    }

	    ttk::frame $p.left
	    ttk::frame $p.right

	    ttk::frame $p.left.ship -padding 2
	    canvas $p.left.ship.screen -width 100m -height 100m {*}$copts
	    pack $p.left.ship.screen -fill both

	    pack $p.left.ship -fill both

	    bind $p.left.ship.screen <Configure> [list ::gui::inv::draw_ship $p.left.ship.screen]
	    
	    ttk::treeview $p.right.list 
	    pack $p.right.list -fill both

	    grid $p.left $p.right -sticky nsew
	    grid columnconfigure $p 0 -weight 1
	    grid columnconfigure $p 1 -weight 1
	    grid rowconfigure $p 0 -weight 1
	    

	}
	proc outline_size {outline} {
	    set minx 0
	    set maxx 0
	    set miny 0
	    set maxy 0
	    foreach {x y} $outline {
		if {$x < $minx} { set minx $x}
		if {$x > $maxx} { set maxx $x}
		if {$y < $miny} { set miny $y}
		if {$y > $maxy} { set maxy $y}
	    }
	    return [list [expr {$maxx - $minx}] [expr {$maxy - $miny}] [expr {($minx+$maxx)/2}] [expr {1.0*($miny+$maxy)/2}]] 
	}
	proc draw_item {widget name position angle outline} {
	    if {$position eq {} || $outline eq {} } {return}
	    if {$angle eq {}} {set angle 1.57}
	    set osize [outline_size $outline]
	    set ow [lindex $osize 0]
	    set oh [lindex $osize 1]
	    set ocx [lindex $osize 2]
	    set ocy [lindex $osize 3]
	    set ww [winfo width $widget]
	    set wh [winfo height $widget]
	    set zoom [expr {min(1.0*$ww/$ow,1.0*$wh/$oh)}]
	    set x0 [expr {round($ww/2)+$ocy*$zoom}]
	    set y0 [expr {round($wh/2)+$ocx*$zoom}]
#	    set a [expr {pi()/2+$angle}]
	    set a $angle
	    set drawn_points {}
	    foreach {x y} $outline {
		set x1 [expr {$x0+($x*$zoom)*cos($a)-($y*$zoom)*sin($a)}]
		set y1 [expr {$y0-(($x*$zoom)*sin($a)+($y*$zoom)*cos($a))}]
		lappend drawn_points $x1 $y1
	    }
	    puts $name
	    if {[$widget gettags $name] != {} } {
		$widget coords $name $drawn_points
	    } else {
		$widget create polygon $drawn_points -tags $name -outline darkgreen
	    }
	}
	proc draw_ship {widget} {
	    set inv [net send "inv list"]
	    foreach item $inv {
		set d [net send "inv get $item"]
		foreach var {outline position angle} {
		    if [dict exist $d $var] {
			set $var [dict get $d $var]
		    } else {
			set $var {}
		    }
		}
		draw_item $widget $item $position $angle $outline
	    }
	}
    }
}
