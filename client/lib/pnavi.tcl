package require Tcl 8.5
package require Tk 8.5

package require ff-client-network

package provide ff-p-navi 0.0

namespace eval tcl::mathfunc {
    proc pi {} {
	return 3.1415926535897932
    }
}

namespace eval gui {
    namespace eval navi {
	set zoom 1 ;# 1mm = 1 km
	proc init {parent} {
	    variable p
	    set p $parent
	    set copts {}

	    set speed ???
	    set position ???

	    foreach opt {background} {
		lappend copts -$opt [::ttk::style lookup TCanvas -$opt]
	    }
	    ttk::frame $p.left 
	    ttk::frame $p.right  -width 100m
	    ttk::frame $p.left.radar -padding 2

	    canvas $p.left.radar.screen -width 100m -height 100m {*}$copts
	    bind $p.left.radar.screen <Configure> [list ::gui::navi::draw_radar_grid $p.left.radar.screen]
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

	proc update_radar {} {
	    variable p
	    set contacts [net send "navi radar"]
	    set speed [net send "navi v"]
	    set position [net send "navi p"]
	    set widget $p.left.radar.screen
	    foreach contact $contacts {
		draw_ship $widget {*}$contact
	    }
	    puts $position
	    # Поправить выдачу команд в навигации!!
	    $widget itemconfigure text_position -text [format "%.1f %.1f" {*}$position]
	    $widget itemconfigure text_speed -text $speed
	}

	proc draw_ship {widget name dist angle {phase 0}} {
	    set offset(x) [expr [winfo width $widget]/2]
	    set offset(y) [expr [winfo height $widget]/2]
	    set scale 10
	    #set a [dict get $sinfo angle]
	    set a [expr $phase+pi()/2]
	    set points {-3 -2 5 0 -3 2 -2 0}
	    set drawn_points {}

# Здесь странное расположение синусов и косинусов, ибо оптимизация
# на самом деле нужно считать x = $offset(x)+$dist*cos($angle),
#			      y = $offset(y)-$dist*sin($angle),
# (минус из-за того, что у canvas ось y направлена вниз),
# но производится поворот: set angle [expr $angle+1.57]
# Дабы не терять точность, проведена замена по формулам
# классической тригонометрии.
	    set x0 [expr {round($offset(x)-$dist*sin($angle))}]
	    set y0 [expr {round($offset(y)-$dist*cos($angle))}]
	    foreach {x y} $points {
#		lappend rotated_points [expr $x*cos($a)-$y*sin($a)+[lindex  $pos 0]*$scale+$offset(x)]m [expr $x*sin($a)+$y*cos($a)+[lindex $pos 1]*$scale+$offset(y)]m
		set x1 [expr {$x0+($x)*cos($a)-$y*sin($a)}]
		set y1 [expr {$y0-(($x)*sin($a)+$y*cos($a))}]
		lappend drawn_points $x1 $y1
	    }
	    if {[$widget gettags $name] != {}} {
		$widget coords $name $drawn_points
	    } else {
		$widget create polygon $drawn_points -tags $name -fill green -outline green
	    }
	}

	proc draw_radar_grid {widget} {
	    set lines 4
	    set x [winfo width $widget]
	    set y [winfo height $widget]
	    set r [expr min($x,$y)/2]
	    $widget delete radargrid
	    $widget create oval [expr $x/2-$r] [expr $y/2-$r] [expr $x/2+$r] [expr $y/2+$r] -outline darkgreen -tag radargrid
	    for {set a 0} {$a < pi()} {set a [expr $a+pi()/$lines]} {
		$widget create line [expr $x/2-$r*cos($a)] [expr $y/2-$r*sin($a)] [expr $x/2+$r*cos($a)] [expr $y/2+$r*sin($a)] -tag radargrid -fill darkgreen
	    }
	    $widget create text 50 10 -tag text_speed -text ??? -fill darkgreen
	    $widget create text 50 [expr $y-10] -tag text_position -text ??? -fill darkgreen

	}
    }
}
