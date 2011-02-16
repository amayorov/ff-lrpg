# Скрипты, которые выполняются присутствуют по умолчанию в безопасном интерпретаторе

set target_angle [navi angle]

auto 0 steer_control {
    global target_angle
    set angle [navi angle]
    set diff [expr $target_angle-$angle]
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
    global target_angle
    set target_angle [expr fmod(([navi angle]+$angle/180*3.14559),360)]
}
