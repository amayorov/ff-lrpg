package require Tcl 8.5

variable objects

namespace eval object {
    namespace export mass create type load
    namespace ensemble create
# Члены словаря "объекты"
#
# type -- тип объекта. Планета, мусор, корабль, бутылка виски в свободном полёте...
# 
# position -- список из координат
# speed -- список из скоростей
# angle -- положение носа.
# angular_speed -- скорость вращения
#
# 
# icells -- информация о внутренней ячейке
# ocells -- информация о внешней ячейке
# В ячейке содержится имя объекта, расположенного в ней.
#
# inventory -- словарь, содержащий информацию о всех объектах корабля
    proc create {type name position {speed {0 0}} {angle 0}} {
	global objects
	set d [dict create type $type position $position speed $speed angle $angle inventory {}]
	set objects($name) $d
	return $d
    }

    proc type {objname} {
	global objects
	return [dict get $objects($objname) type]
    }
    
    proc mass {objname} {
	return 1
    }

    proc load {objname what} {
	global objects
	set inv [dict get $objects($objname) inventory]
	set whatname [dict get $what name]
	dict append inv $whatname $what
	dict set objects($objname) inventory $inv
    }

}

namespace eval ship {
# команда  ship позволяет делать дополнительные операции над объектом, если он является кораблём
    namespace export tanks engines
    namespace ensemble create
# callsign -- позывной -- перенести в рубку
# controls -- словарь, содержащий состояние "рычагов управления" корабля -- перенести в рубку
    proc engines {s} {
	set inv [dict get $s inventory]
	set result {}
	dict for {key val} $inv {
	    if {[dict get $val type]=="engine"} {
		lappend result $key
	    }
	}
	return $result
    }

    proc prep_engine {engine tank} {
    }
}

namespace eval item {
}

namespace eval engine {

# Члены словаря engine:
# throttle -- состояние "ручки газа", 0..1
# tank -- топливный бак, от которого работатет двигатель
# sid -- имя объекта, на котором стоит двигатель. В принципе, можно считать бутылку шампанского кораблём, обладающим двигателем... Планета -- это, в общем-то тоже космический корабль, только здоровый и без двигателей (хотя...)
# +дополнительные параметры...
# angle -- угол в радианах, на который двигатель отличается от носа корабля... Можно сделать корабль (читай, ракету) в виде летающего скраерского значка, причём траектория полёта этой хрени будет вполне в скавенском духе (йопнутая на всю голову)
    namespace export burn consumption usage force create state
    namespace ensemble create

    proc state {engine} {
# возвращает состояние двигателя
	return 1.
    }

    proc force {engine} {
# возвращает тягу двигателя
	set throttle [dict get $engine throttle]
	set state [engine state $engine]
	return [expr 1.*$throttle]
    }

    proc consumption {engine} {
	#Процедура возвращает потребление топлива двигателем в зависимости от состояния ручки газа и т.п.
	if {$engine == {} } {
	    # Внезапно, двигатель не найден
	} else {
	    set throttle [dict get $engine throttle]
	    set state [engine state $engine]
	    return [expr 1.0*$throttle]
	}
    }

    proc burn {engine dt} {
	global objects
	set sid [dict get $engine sid]
	if {$sid == {} } {
# Двигатель не установлен на корабль
	    puts stderr "Engine not installed!"
	    return
	}
	set sdata $objects($sid)
	set tank [dict get $engine tank]
	if {$tank == {} || [dict get $sdata inventory $tank type] != "tank"} {
# То, к чему подключён двигателем, баком не является...
	    puts stderr "No tank connected!"
	    return
	}
	set mass [object mass $sdata]
	set leftfuel [dict get $sdata inventory $tank left]
	set reqfuel [expr 1.0*[engine consumption $engine]*$dt]
	if {$leftfuel < $reqfuel} {
	    set fraction [expr 1.0*$leftfuel/$reqfuel]
	} else {
	    set fraction 1.0
	}
# Убираем топливо...
	dict set sdata inventory $tank left [expr $leftfuel-$fraction*$reqfuel]
# Добавляем приращение скорости...
	set force [expr [engine force $engine]*$fraction]
	set current_speed [dict get $sdata speed]
	
	set angle [expr [dict get $sdata angle]+[dict get $engine angle]]
	set new_speed {}
	foreach c $current_speed op {cos sin} {
	    lappend new_speed [expr [concat "$c+$force/$mass*$op" "($angle)"]]
	}

	dict set sdata speed $new_speed

	set objects($sid) $sdata

	puts "left: $leftfuel, force $force"
    }

    proc create {name} {
	return [dict create name $name type "engine" throttle 0. sid {} tank {} angle -3.14159]
    }
}

proc tick {obj dt} {
    global objects
    set damping 0.5
    
    if {[object type $obj]=="ship"} {
	foreach enginename [ship engines $objects($obj)] {
	    set eng [dict get $objects($obj) inventory $enginename]
	    engine burn $eng $dt
	}
    }

    # Изменяем координаты корабля
    set position [dict get $objects($obj) position]
    set speed [dict get $objects($obj) speed]
    set new_position {}
    foreach c $position s $speed {
	lappend new_position [expr $c+$s*$dt]
    }

# "Вязкость космоса"
    set new_speed {}
    foreach s $speed {
	lappend new_speed [expr $s*(1.-$damping*$dt)]
    }
    
    dict set objects($obj) position $new_position
    dict set objects($obj) speed $new_speed
}
