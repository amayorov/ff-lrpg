package require Tcl 8.5
package provide ff-object 0.0

variable objects

proc is {object type} {
    set objtype [dict get $object type]
    if {[lsearch -exact $objtype $type] > -1} {
	return yes
    } else {
	return no
    }
}

namespace eval object {
    namespace export inventory mass create type 
    namespace ensemble create
# Члены словаря "объекты"
#
# type -- тип объекта. Планета, мусор, корабль, бутылка виски в свободном полёте...
# Главное -- что в свободном полёте. То, что летать само по себе не способно,
# считается не объектом, а балластом^Wгрузом
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

    namespace eval inventory { ;# Сокращение от inventory, ибо долго писать и много придётся использовать
	namespace export load list get set
	namespace ensemble create

	proc load {objname what} {
# load -- это загрузить в инвентарь и ячейки. Для фунциклирования необходимо подключить оборудование специальной командой
	    global objects
	    ::set inv [dict get $objects($objname) inventory]
	    ::set whatname [dict get $what name]
	    dict append inv $whatname $what
	    dict set objects($objname) inventory $inv
	}

	proc list {objname} {
	    # возвращает список предметов в инвентаре
	    global objects
	    ::set invlist [dict keys [dict get $objects($objname) inventory]]
	    return $invlist
	}
	
	proc exists {objname invname} {
	    global objects
	    return [dict exists $objects($objname) inventory $invname]
	}
	proc get {objname invname} {
	    global objects
	    if [exists $objname $invname] {
		return [dict get $objects($objname) inventory $invname]
	    } else {
		return
	    }
	}
	proc set {objname invname args} {
	    global objects
	    if {[exists $objname $invname]} {
		foreach {key val} $args {
		    dict set objects($objname) inventory $invname $key $val
		}
	    }
	}
    }

}

namespace eval ship {
# команда  ship позволяет делать дополнительные операции над объектом, если он является кораблём
    namespace export tanks engines throttle engine turn
    namespace ensemble create
# callsign -- позывной -- перенести в рубку
    proc engines {s} {
	set inv [dict get $s inventory]
	set result {}
	dict for {key val} $inv {
	    if {[is $val engine]} {
		lappend result $key
	    }
	}
	return $result
    }
    proc tanks {s} {
	set inv [dict get $s inventory]
	set result {}
	dict for {key val} $inv {
	    if {[is $val tank]} {
		lappend result $key
	    }
	}
	return $result
    }

    proc throttle {ship engine value} {
	if {$value < 0} { set value 0} 
	if {$value > 1} { set value 1} 
	if {[is [object inv get $ship $engine] engine]} {
	    object inv set $ship $engine throttle $value
	}
	return [list $engine $value]
    }

    proc turn {ship angle} {
	global objects
	set current [dict get $objects($ship) angle]
	dict set objects($ship) angle [expr $current+$angle]
	return $angle
    }

    proc steer {ship angle} {
	turn $ship [expr 3.14159*$angle/180]
	return $angle
    }

    namespace eval engine {

# Члены словаря engine:
# throttle -- состояние "ручки газа", 0..1
# tank -- топливный бак, от которого работатет двигатель
# sid -- имя объекта, на котором стоит двигатель. В принципе, можно считать бутылку шампанского кораблём, обладающим двигателем... Планета -- это, в общем-то тоже космический корабль, только здоровый и без двигателей (хотя...)
# +дополнительные параметры...
# angle -- угол в радианах, на который двигатель отличается от носа корабля... Можно сделать корабль (читай, ракету) в виде летающего скраерского значка, причём траектория полёта этой хрени будет вполне в скавенском духе (йопнутая на всю голову)
	namespace export burn consumption usage force state install connect
	namespace ensemble create

	proc state {engine} {
# возвращает состояние двигателя
	    return 1.
	}

	proc force {engine} {
# возвращает тягу двигателя
	    set throttle [dict get $engine throttle]
	    return [expr 1.*$throttle]
	}

	proc consumption {engine} {
	    #Процедура возвращает потребление топлива двигателем в зависимости от состояния ручки газа и т.п.
	    if {$engine == {} } {
		# Внезапно, двигатель не найден
	    } else {
		set throttle [dict get $engine throttle]
		set state [state $engine]
		return [expr 1.0*$throttle]
	    }
	}

	proc burn {engine dt} {
	    if {[interp issafe {}]} {
		# смертный решил воспользоваться... Обломись =)
		# надо бы перенести отсюда
		return
	    }
	    global objects
	    set sid [dict get $engine sid]
	    if {$sid == {} } {
# Двигатель не установлен на корабль
		puts stderr "Engine not installed!"
		return
	    }
	    set tank [dict get $engine tank]
	    if {![is [object inv get $sid $tank] tank]} {
# То, к чему подключён двигателем, баком не является...
		puts stderr "No tank connected!"
		return
	    }
	    set mass [object mass $objects($sid)]
	    set leftfuel [dict get $objects($sid) inventory $tank left]
	    set reqfuel [expr 1.0*[consumption $engine]*$dt]
	    if {$leftfuel < $reqfuel} {
		set fraction [expr 1.0*$leftfuel/$reqfuel]
	    } else {
		set fraction 1.0
	    }
# Убираем топливо...
	    dict set objects($sid) inventory $tank left [expr $leftfuel-$fraction*$reqfuel]
# Добавляем приращение скорости...
	    set force [expr [force $engine]*$fraction]
	    set current_speed [dict get $objects($sid) speed]
	    
	    set angle [expr [dict get $objects($sid) angle]+[dict get $engine angle]]
	    set new_speed {}
	    foreach c $current_speed op {cos sin} {
		lappend new_speed [expr [concat "$c+$force/$mass*$op" "($angle)"]]
	    }

	    dict set objects($sid) speed $new_speed
	}

	proc install {engine ship {angle 0}} {
# странная процедура, надо бы придумать, что с ней делать
# для простого смертного -- слишком большая власть
	    if {[interp issafe {}]} {
		# смертный решил этой властью воспользоваться...
		return
	    }
	    global objects
	    set inv [dict get $objects($ship) inventory]
	    set enginename [dict get $engine name]
	    if {![dict exists $inv $enginename]} {
		# Подключаем незагруженный двигатель
		puts stderr "Installing non-loaded engine!!!"
		return
	    } 
	    dict set objects($ship) inventory $enginename throttle 0.
	    dict set objects($ship) inventory $enginename sid $ship
	    dict set objects($ship) inventory $enginename angle $angle
	    dict set objects($ship) inventory $enginename tank {}
	}

	proc connect {engine tank} {
	    global objects
	    set sid [dict get $engine sid]
	    if {$sid == {} } {
		puts stderr "Trying to install unconnected engine!"
		return
	    }
	    set enginename [dict get $engine name]
	    dict set objects($sid) inventory $enginename tank $tank
	}
    }
}
proc tick {obj dt} {
    global objects
    set damping 0.5
    
    if {[object type $obj]=="ship"} {
	foreach enginename [ship engines $objects($obj)] {
	    set eng [dict get $objects($obj) inventory $enginename]
	    ship engine burn $eng $dt
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
