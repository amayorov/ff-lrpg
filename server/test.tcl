object create ship "Destiny" {0 0} {0 0}

set t [item create tank left 10.]
set e [item create engine tank $t throttle 0 angle 0 position {0 0}]
set e1 [item create engine tank $t throttle 0 angle 0 position {0 10}]
set e2 [item create engine tank $t throttle 0 angle 0 position {0 -10}]

object inv load Destiny $e {main}
object inv load Destiny $e1 {left}
object inv load Destiny $e2 {right}
object inv load Destiny $t {main tank}

object create ship "Foobar" {1 1} {0 0}

set t [item create tank left 10.]
set e [item create engine tank $t throttle 0 angle 0]

object inv load Foobar $e {main}
object inv load Foobar $t {main tank}
