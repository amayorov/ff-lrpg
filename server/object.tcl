package require Tcl 8.5
package provide ff-object 0.0

variable objects
variable items

proc is {object type} {
    set objtype [dict get $object type]
    if {[lsearch -exact $objtype $type] > -1} {
	return yes
    } else {
	return no
    }
}

namespace eval object {
    namespace export inventory mass create type xsection
    namespace ensemble create
# Члены словаря "объекты"
#
# type -- тип объекта. Планета, мусор, корабль, бутылка виски в свободном полёте...
# Главное -- что в свободном полёте. То, что летать само по себе не способно,
# считается не объектом, а балластом^Wгрузом
# 
# position -- список из координат
# speed -- список из скоростей
#
# angle -- положение носа.
# aspeed -- угловая скорость
#
# mass -- масса объекта
# mass_center -- координаты центра масс
#
# xsection -- эффективная площадь сечения {лобовая боковая}
#
# forces -- список {сила {точка приложения}}
#
# icells -- информация о внутренней ячейке
# ocells -- информация о внешней ячейке
# В ячейке содержится имя объекта, расположенного в ней.
#
# inventory -- словарь, содержащий предметы на корабле и их назначения
# например, engine "Foobar"
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
    
    proc mass_center {objname} {
	return {0 0}
    }

    proc xsection {objame} {
	return {1 5}
    }

    namespace eval inventory { 
	namespace export load list get set
	namespace ensemble create

	proc load {objname id role} {
# load -- это загрузить в инвентарь и ячейки. 
	    # Загружается предмет с id под именем name
	    global objects
	    global items
	    if {![dict exists $objects($objname) inventory $role]} {
		dict set objects($objname) inventory $role $id
		dict set items($id) ship $objname
	    }
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
	    global items
	    if [exists $objname $invname] {
		set id [dict get $objects($objname) inventory $invname]
		return $items($id)
	    } else {
		return
	    }
	}
	proc set {objname invname args} {
	    global objects
	    if {[exists $objname $invname]} {
		set id [dict get $objects($objname) inventory $invname]
		foreach {key val} $args {
		    dict set items($id) $key $val
		}
	    }
	}
    }

}

namespace eval item {
    namespace export create
    namespace ensemble create


    # словарь item содержит обязательные члены: 
    # type
    # mass
    # ship
    proc create_id {type} {
	return ${type}_[clock clicks]
    }
    proc create {type args} {
	global items
	set id [create_id $type]
# создать новый id, записать его в массив items
	foreach {tag value} [concat [list id $id type $type ship {}] $args] {
	    dict set items($id) $tag $value
	}
	return $id
    }
}

namespace eval ship {
# команда  ship позволяет делать дополнительные операции над объектом, если он является кораблём
    namespace export tanks engines throttle engine turn
    namespace ensemble create
# callsign -- позывной -- перенести в рубку
    proc engines {s} {
	global items
	set inv [dict get $s inventory]
	set result {}
	dict for {key val} $inv {
	    if {[is $items($val) engine]} {
		lappend result $val
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

    proc throttle {ship ename value} {
	# можно сделать так, чтобы этой командой крутилось состояние маршевого двигателя, который имеен имя "engine"
	global items
	global objects
	if {$value < 0} { set value 0} 
	if {$value > 1} { set value 1} 
	set eid [dict get $objects($ship) inventory $ename]
	if {[is $items($eid) engine]} {
	    dict set items($eid) throttle $value
	}
	return [list $ename $value]
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

	proc force {eid} {
# возвращает тягу двигателя
	    global items
	    set engine $items($eid)
	    set throttle [dict get $engine throttle]
	    return [expr 1.*$throttle]
	}

	proc consumption {eid} {
	    #Процедура возвращает потребление топлива двигателем в зависимости от состояния ручки газа и т.п.
	    global items
	    set engine $items($eid)
	    if {$engine == {} } {
		# Внезапно, двигатель не найден
	    } else {
		set throttle [dict get $engine throttle]
		set state [state $engine]
		return [expr 1.0*$throttle]
	    }
	}

	proc burn {eid dt} {

	    global objects
	    global items

	    set engine $items($eid)
	    set sid [dict get $engine ship]
	    if {$sid == {} } {
# Двигатель не установлен на корабль
		puts stderr "Engine not installed!"
		return
	    }
	    set tid [dict get $engine tank]
	    set tank $items($tid)
	    if {![is $tank tank]} {
# То, к чему подключён двигателем, баком не является...
		puts stderr "No tank connected!"
		return
	    }
	    set mass [object mass $objects($sid)]
	    set leftfuel [dict get $tank left]
	    set reqfuel [expr 1.0*[consumption $eid]*$dt]
	    if {$leftfuel < $reqfuel} {
		set fraction [expr 1.0*$leftfuel/$reqfuel]
	    } else {
		set fraction 1.0
	    }
# Убираем топливо...
	    dict set items($tid) left [expr $leftfuel-$fraction*$reqfuel]
# Добавляем приращение скорости...
	    set abs_force [expr [force $eid]*$fraction]
	    
	    set angle [expr [dict get $objects($sid) angle]+[dict get $engine angle]]
	    
	    set force [list [expr $abs_force*cos($angle)] [expr $abs_force*sin($angle)]]

	    dict lappend objects($sid) force [list $force {0 0}]

	}

    }
}

proc do_physic {obj dt} {
# Вычисляет все силы, действющие на корабль
    global objects
    set pi 3.14159
    set viscosity 0.1

    if {[object type $obj]=="ship"} {
	foreach eid [ship engines $objects($obj)] {
	    ship engine burn $eid $dt
	}
    }

    set speed [dict get $objects($obj) speed]
    set angle [dict get $objects($obj) angle]
    set xsection [object xsection $obj]

    set mass [object mass $obj]
    
    set friction_force {}
    
    set projected_xsection {}
    lappend projected_xsection [expr abs([lindex $xsection 0]*cos($angle)+[lindex $xsection 1]*sin($angle))]
    lappend projected_xsection [expr abs([lindex $xsection 0]*sin($angle)+[lindex $xsection 1]*cos($angle))]

    foreach s $speed c $projected_xsection {
	if {$speed > 0} {
	    set sign -1.
	} else {
	    set sign 1.
	}
	lappend friction_force [expr $sign*$viscosity*($s**2)*$c] 
    }
    
    set ff_fixed {}
    set ff_max_list {}
    foreach s $speed f $friction_force {
	set ff_max [expr -1.*$s/$dt*$mass]
	if {abs($f) > abs($ff_max)} {
	    lappend ff_fixed $ff_max
	} else {
	    lappend ff_fixed $f
	}
	lappend ff_max_list $ff_max
    }
	puts "Force: $friction_force (max $ff_max_list)"

    dict lappend objects($obj) force [list $ff_fixed {0 0}]
}

proc do_kinematic {obj dt} {
# считает движеие корабля
    global objects

    set position [dict get $objects($obj) position]
    set speed [dict get $objects($obj) speed]
    set forces [dict get $objects($obj) force]

    set mass [object mass $obj]

    # Складываем силы
    set force {0 0}
    foreach f $forces {
	foreach i {0 1} {
	    lset force $i [expr [lindex $force $i]+[lindex $f 0 $i]]
	}
    }

    # Изменяем координаты корабля в фазовом пространстве

    set new_speed {}
    foreach s $speed f $force {
	lappend new_speed [expr $s+1.0*$f/$mass*$dt]
    }

    set new_position {}
    foreach c $position s $speed {
	lappend new_position [expr $c+$s*$dt]
    }
    
    dict set objects($obj) position $new_position
    dict set objects($obj) speed $new_speed
    dict set objects($obj) force {}
}
