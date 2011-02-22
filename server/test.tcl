object create ship "Destiny" {0 0} {0 0}

set h [item create hull mass 1 outline {30 0 0 10 5 0 0 -10} position {0 0}]
set t [item create tank left 1000.]
set e [item create engine tank $t throttle 0 angle 0 position {0 0}]
set e1 [item create engine tank $t throttle 0 angle 0 position {0 10}]
set e2 [item create engine tank $t throttle 0 angle 0 position {0 -10}]

object inv load Destiny $h {hull}
object inv load Destiny $e {main}
object inv load Destiny $e1 {left}
object inv load Destiny $e2 {right}
object inv load Destiny $t {main tank}

object create ship "Foobar" {0 0} {0 0} 1.57

set t [item create tank left 10.]
set e [item create engine tank $t throttle 0 angle 0 position {0 0}]
set e1 [item create engine tank $t throttle 0 angle 1.57 position {100 0}]
set e2 [item create engine tank $t throttle 0 angle -1.57 position {100 0}]
set e3 [item create engine tank $t throttle 0 angle 1.57 position {-100 0}]
set e4 [item create engine tank $t throttle 0 angle -1.57 position {100 0}]

object inv load Foobar $e {main}
object inv load Foobar $e1 {l1}
object inv load Foobar $e2 {r1}
object inv load Foobar $e3 {l2}
object inv load Foobar $e4 {r2}
object inv load Foobar $t {main tank}

object create asteroid "A00001" {100 10}
object create asteroid "A00002" {50 70}
object create asteroid "A00003" {-10 50}
object create asteroid "A00004" {-30 -30}


puts [object inv get Destiny main]
