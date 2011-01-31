package require Tcl 8.5

# Файл содержит одну-единственную команду user
# Через неё делается всё...
namespace eval user {
    namespace export run allow deny
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

    proc run {ship cmd} {
	variable allowed
	interp create -safe $ship
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
	catch {interp eval $ship $cmd} result
	interp delete $ship
	return $result
    }
}

# Пример использовния:
#user allow ::user::shipname ::user::shipname {$ship} -- передаётся обязательный параметр
#user allow ::test::b -- параметр не передаётся, имя комадны в дочернем интерпретаторе совпадает с родительским

#user run "foo" {test b}
#user run "foo" {puts [user shipname]}
#user run "foo" {user deny} -- не работает, ибо не разрешено простому смертному
