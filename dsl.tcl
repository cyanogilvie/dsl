#!/usr/bin/env kbskit8.6

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
proc dsl::dsl_eval {interp dsl_commands dsl_script args} { #<<<
	set aliases_old	{}
	foreach {cmdname cmdargs cmdbody} [dsl::decomment $dsl_commands] {
		set alias	[interp alias $interp $cmdname]
		if {$alias eq ""} {
			dict set aliases_old $cmdname [list {}]
		} else {
			dict set aliases_old $cmdname [list [interp target $interp $cmdname] $alias]
		}

		interp alias $interp $cmdname {} apply [list $cmdargs $cmdbody [uplevel {namespace current}]] {*}$args
	}

	try {
		interp eval $interp $dsl_script
	} finally {
		dict for {cmdname oldalias} $aliases_old {
			interp alias $interp $cmdname {*}$oldalias
		}
	}
}

#>>>

