source object.tcl

object create ship "Waa" {0 0} {0 0}

set e [dict create name "Blah" type engine]
set t [dict create name "Can" type tank left 10.]

object inv load Waa $e
object inv load Waa $t

ship engine install [object inv get Waa Blah] Waa
ship engine connect [object inv get Waa Blah] Can

#object inv set Waa Blah throttle 0.1
ship throttle Waa Blah 0.1

puts [object inv list Waa]

while yes {
    foreach obj [array names objects] {
	puts "Speed [dict get $objects($obj) speed]"
	puts "Coords [dict get $objects($obj) position]"
	tick $obj 1
    }
    puts {}
    after 1000
}
