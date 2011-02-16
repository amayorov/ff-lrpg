package require Tcl 8.5
package require ff-object
package provide ff-user 0.0

# Файл содержит одну-единственную команду user
# Через неё делается всё...
namespace eval user {
    namespace export run allow deny source auto do_autos init
    namespace ensemble create

    set allowed {}

    proc shipname {ship} {
	return $ship
    }

    proc allow {cmd {alias {}} args} {
	variable allowed
	if {$alias != {} } {
	    lappend allowed [list $alias $cmd $args]
	} else {
	    lappend allowed [list $cmd $cmd $args]
	}
    }

    proc deny {cmd} {
	variable allowed
	set idx [lsearch -all -index 0 $allowed $cmd]
	foreach i $idx {
	    set allowed [lreplace $allowed $i $i]
	}
    }

    proc init {ship} {
	global objects
	#interp create -safe $ship
	variable allowed
	# выключить потом, нечего гадить в stdout
	interp share {} stdout $ship
# Может, вообще set выключить, заодно и шаманить с внутренним состоянием сервера не получится...
	foreach i $allowed {
	    $ship alias [lindex $i 0] [lindex $i 1] {*}[subst -nocommands [lindex $i 2]]
	}
	set ns [interp eval $ship namespace children]
	set aliases [interp eval $ship interp aliases]
	foreach n $ns {
	    if {$n == "::tcl"} { continue }
	    # спорный вопрос, надо бы потестить на предмет взлома
	    interp eval $ship namespace inscope $n {namespace export *}
	    interp eval $ship namespace inscope $n {namespace ensemble create}
	}
	user source $ship default_scripts.tcl
	#interp delete $ship
    }

    proc run {ship cmd} {
	catch {interp eval $ship $cmd} result
	return $result
    }

    proc unknown {ship cmd args} {
	set cmdlist [interp eval $ship [list info commands $cmd*]]
	if {[llength $cmdlist] == 1} {
	    set cmd $cmdlist
	    return [interp eval $ship [list $cmd {*}$args]]
	} elseif {[llength $cmdlist] == 0} {
	    return -code error "invalid command name \"$cmd\""
	} else {
	    return -code error [concat "unknown or ambiguous command \"$cmd\": must be" [join [lrange $cmdlist 0 end-1] {, }] "or" [lindex $cmdlist end]]
	}
    }
    proc auto {ship id name code} {
	global objects
	dict set objects($ship) auto $id $code
	return {}
    }
    proc source {ship fname} {
	set fh [open $fname "r"]
	set script [read $fh]
	close $fh
	interp eval $ship $script
    }

    proc do_autos {ship} {
	global objects
	set keys [dict get $objects($ship) auto]
	dict for {key  code} $keys {
	    interp eval $ship $code
	}
    }
}

# Пример использовния:
#user allow ::user::shipname ::user::shipname {$ship} -- передаётся обязательный параметр
#user allow ::test::b -- параметр не передаётся, имя комадны в дочернем интерпретаторе совпадает с родительским

#user run "foo" {test b}
#user run "foo" {puts [user shipname]}
#user run "foo" {user deny} -- не работает, ибо не разрешено простому смертному
