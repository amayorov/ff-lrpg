source object.tcl

object create ship "Waa" {0 0} {0 0}

set e [dict create name "Blah" type engine]
set t [dict create name "Can" type tank left 1.]

object load Waa $e
object load Waa $t

engine install [dict get $objects(Waa) inventory Blah] Waa
engine connect [dict get $objects(Waa) inventory Blah] Can

dict set objects(Waa) inventory Blah throttle 0.1

puts [dict keys [dict get $objects(Waa) inventory]]

while yes {
    foreach obj [array names objects] {
	puts [dict get $objects($obj) speed]
	tick $obj 1
    }
    puts {}
    after 1000
}
