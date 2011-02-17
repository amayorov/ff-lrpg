# Скрипты, которые выполняются присутствуют по умолчанию в безопасном интерпретаторе

set course [navi angle]

proc ::tcl::mathfunc::pi {} {
    return 3.1415926535897932
}

# Ограничивает угол к [-pi:pi]
proc ::tcl::mathfunc::limit {x} {
    set n [expr {floor($x/pi())}]
    if {abs(fmod($n,2)) == 1.0} {
	set n [expr {$n+1}]
    }
    return [expr {$x-$n*pi()}]

}

auto 0 steer_control {
    global course
    set angle [navi angle]
    set diff [expr {limit($course-$angle)}]
    if {abs($diff) > 0.01} {
	set power 0.01
    } else {
	set power 0
    }
    if {$diff > 0} {
	throttle left 0
	throttle right $power
    } else {
	throttle right 0
	throttle left $power
    }
}

proc dsteer {angle} {
    global course
    set course [expr fmod(([navi angle]+(-1.)*$angle/180*pi()),360)]
}
