object create ship "Destiny" {0 0} {0 0}

set t [item create tank left 10.]
set e [item create engine tank $t throttle 0 angle 0]

object inv load Destiny $e {main}
object inv load Destiny $t {main tank}

