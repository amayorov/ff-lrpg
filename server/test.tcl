object create ship "Destiny" {0 0} {0 0}

set e [dict create name "Blah" type engine]
set t [dict create name "Can" type tank left 10.]

object inv load Destiny $e
object inv load Destiny $t

ship engine install [object inv get Destiny Blah] Destiny
ship engine connect [object inv get Destiny Blah] Can


