object create ship "Destiny" {0 0} {0 0}

set e [dict create name "Blah" type engine]
set t [dict create name "Can" type tank left 100.]

object inv load Destiny $e
object inv load Destiny $t

ship engine install [object inv get Destiny Blah] Destiny
ship engine connect [object inv get Destiny Blah] Can


object create ship "Foobar" {1 1} {0 0}

set e1 [dict create name "Blah" type engine]
set t1 [dict create name "Can" type tank left 100.]

object inv load Foobar $e1
object inv load Foobar $t1

ship engine install [object inv get Foobar Blah] Foobar
ship engine connect [object inv get Foobar Blah] Can
