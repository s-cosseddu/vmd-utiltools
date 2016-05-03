## \file randomSphere.tcl --
#
#  Return points a matrix filled by random numbers 
#
# Salvatore Cosseddu 2013-2016
#
# SYNOPSIS:
#   ::utiltools::random::randomSphere N center r <cutoff (0)> <maxIter (100)> 
#
# OPTIONS
# @param rows 
# @param cols 
# @return List \{ row1 row2 ... rowNcols \}
#
# Ex.
#  ::utiltools::random::RandomMatrix 3 100 ;# 100 random cartesian coordinates 

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval random {
	# declaring namespace
	namespace export randomMatrix
    }
}

proc ::utiltools::mol::RandomMatrix { rows cols } {
    set result {}
    for { set j 0} { $j < $cols } { incr j} {
	set row {}
	for { set i 0} { $i < $rows } { incr i} {
	    lappend row [expr {rand()*2-1}]
	}
	lappend result $row
    }
    return $result
}
