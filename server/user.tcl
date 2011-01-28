package require Tcl 8.5

# Файл содержит одну-единственную команду user
# Через неё делается всё...
namespace eval user {
    namespace export run
    namespace ensemble create

    namespace eval ui {
	namespace export engine test
	namespace ensemble create
	proc test {} {
	    puts [shipname]
	}
    }

    proc run {ship cmd} {
	interp create -safe $ship
	$ship alias shipname ::user::shipname $ship
	$ship alias ui ::user::ui
	interp eval $ship $cmd
	interp delete $ship
    }
}

user run "foo" shipname
