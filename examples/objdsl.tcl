#!/usr/bin/env cfkit8.6

tcl::tm::path add [file normalize [file join [file dirname [info script]] .. tm tcl]]

package require dsl

oo::class create Foo {
	variable {*}{
		prefix
	}

	constructor {pref} {
		#my variable prefix

		#puts "constructor prefix var: ([namespace which -variable prefix])"
		#puts "constructor prefix varname: ([my varname prefix])"
		#puts "namespace path: ([namespace path])"

		set prefix	$pref
	}

	method go {script} {
		set slave	[interp create -safe]
		try {
			dsl::dsl_eval $slave {
				hello {thing} {
					variable prefix
					#my variable prefix

					#puts "prefix var: ([namespace which -variable prefix])"

					puts "${prefix}hello $thing \[[my _length $thing]\]"
				}
			} $script
		} finally {
			if {[interp exists $slave]} {
				interp delete $slave
			}
		}
	}

	method _length {str} {
		string length $str
	}
}

Foo create foo "foo: "
Foo create bar "bar: "

foo go {
	hello world
}

bar go {
	hello kitty
}
