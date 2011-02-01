
set sd [socket 127.0.0.1 9999]
fconfigure $sd -buffering line

puts $sd {auth {Destiny foobar}}
while {yes} {
    gets stdin cmd
    puts $sd [list test $cmd]
    set ans [gets $sd]
    puts [lindex $ans 1]
}
