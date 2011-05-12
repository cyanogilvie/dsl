# vim: ft=tcl foldmethod=marker foldmarker=<<<,>>> ts=4 shiftwidth=4

namespace eval dsl {}

proc dsl::decomment {in} { #<<<
	set out	""

	foreach line [split $in \n] {
		if {[string index [string trim $line] 0] eq "#"} continue
		append out	$line "\n"
	}

	return $out
}

#>>>
# Reserved dsl commands:
#	if
#	info
#	rename
#	apply
#	foreach
#	namespace
proc dsl::dsl_eval {interp dsl_commands dsl_script args} { #<<<
	set aliases_old	{}
	set tmpns		::_dsl_[incr ::dsl::seq]
	set cmds		{}
	try {
		interp eval $interp [format {namespace eval %s {}} [list $tmpns]]
		foreach {cmdname cmdargs cmdbody} [dsl::decomment $dsl_commands] {
			if {$cmdname in {if info rename apply foreach namespace}} {
				error "\"$cmdname\" is a reserved word and cannot be used for a DSL command"
			}
			interp eval $interp [format {
				if {[info commands ::%1$s] ne ""} {
					rename ::%1$s %2$s::%1$s
				}
			} [list $cmdname] [list $tmpns]]
			lappend cmds	$cmdname
			#set alias	[interp alias $interp $cmdname]
			#if {$alias eq ""} {
			#	dict set aliases_old $cmdname [list {}]
			#} else {
			#	dict set aliases_old $cmdname [list [interp target $interp $cmdname] $alias]
			#}

			interp alias $interp $cmdname {} apply [list $cmdargs $cmdbody [uplevel {namespace current}]] {*}$args
		}

		if {$interp eq {}} {
			apply [list {} $dsl_script [uplevel 1 {namespace current}]]
		} else {
			interp eval $interp $dsl_script
		}
	} finally {
		#dict for {cmdname oldalias} $aliases_old {
		#	interp alias $interp $cmdname {*}$oldalias
		#}
		interp eval $interp [format {
			apply {{} {
				foreach cmd %2$s {
					rename ::$cmd {}
					if {[info commands %1$s::$cmd] ne ""} {
						rename %1$s::$cmd ::$cmd
					}
				}
				namespace delete %1$s
			}}
		} [list $tmpns] [list $cmds]]
	}
}

#>>>

