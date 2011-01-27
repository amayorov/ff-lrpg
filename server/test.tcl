source object.tcl

object create ship "Waa" {0 0} {0 0}

set e [engine create "Blah"]

dict set e throttle 0.1

set t [dict create name "Can" type tank left 1.]
dict set e sid Waa
dict set e tank Can

object load Waa $e
object load Waa $t

puts [dict keys [dict get $objects(Waa) inventory]]

while yes {
    foreach obj [array names objects] {
	puts [dict get $objects($obj) position]
	tick $obj 1
    }
    puts {}
    after 1000
}
