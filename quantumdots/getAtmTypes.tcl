## \file getAtmTypes.tcl --
#
# Search atoms of the surface and on the bulk according to the
# first_neighbour_distances, the distance of the first neighbours of the same type.
# first_neighbour_distances is user-provided.
#
# Salvatore Cosseddu 2013-2015
#
# SYNOPSIS:
#   ::utiltools::quantumdot::getAtmTypes <molID> <list atomnames> <list first_neighbour_distances> \[<frame (0)>\]
#
# OPTIONS
# @param molID
# @param atomnames
# @param first_neighbour_distances
# @param frame (optional, default=0)
# @return list \[array get CoordNumLists \]
#	       \[array get CoordNums \]
#	       \[array get surfaceIDs \]
#	       \[array get bulkIDs \]
# USAGE
# set AtmTypList \[::utiltools::quantumdot::getAtmTypes top \{Cd Se\} \{4.35 4.35\}\]
# array set CoordNumLists \[lindex $AtmTypList 0\]
# array set CoordNums     \[lindex $AtmTypList 1\]
# array set surfaceIDs	  \[lindex $AtmTypList 2\]
# array set bulkIDs       \[lindex $AtmTypList 3\]

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval quantumdot {
	# declaring namespace
	namespace export getAtmTypes
    }
}

proc ::utiltools::quantumdot::usage_getAtmTypes {} {
    puts stderr "
Search atoms of the surface and on the bulk according to the
first_neighbour_distances, the distance of the first neighbours of the same type.
first_neighbour_distances is user-provided.

Salvatore Cosseddu 2013-2015

SYNOPSIS:
  ::utiltools::quantumdot::getAtmTypes <molID> <list atomnames> <list first_neighbour_distances> \[<frame (0)>\]

OPTIONS
- molID
- atomnames
- first_neighbour_distances
- frame (optional, default=0)

- return list \[array get CoordNumLists \]
	       \[array get CoordNums \]
	       \[array get surfaceIDs \]
	       \[array get bulkIDs \]
USAGE
set AtmTypList \[::utiltools::quantumdot::getAtmTypes top \{Cd Se\} \{4.35 4.35\}\]
array set CoordNumLists \[lindex $AtmTypList 0\]
array set CoordNums     \[lindex $AtmTypList 1\]
array set surfaceIDs    \[lindex $AtmTypList 2\]
array set bulkIDs       \[lindex $AtmTypList 3\]
    "

}


proc ::utiltools::quantumdot::getAtmTypes {molID atomnames first_neighbour_distances {frame 0}} {
       
    if {[llength $molID] == 0 ||
	[llength $atomnames]  == 0 ||
	[llength $first_neighbour_distances] == 0 } {
	::utiltools::quantumdot::usage_getAtmTypes
	return
    }
	
    array set CoordNumLists {}
    array set CoordNums {}
    
    array set surfaceIDs {}
    array set bulkIDs {}
    
    # computing number of same type  neighbours within first_neighbour_distance
    foreach atm $atomnames d $first_neighbour_distances {
	# compute number of nearest atoms of the same type
	# ::utiltools::measure::NeighAtms molID sel1 sel2 r start end coordNum
	set CoordNumLists($atm) [::utiltools::measure::NeighAtms $molID "name $atm" "name $atm" $d $frame $frame T]

	# sorting type  of atoms according to number of nearest atoms of the same type
	set CoordNums($atm) [lsort -integer -unique [lindex $CoordNumLists($atm) 1]]

	# atom in the bulk are the more connected
	set bulkConnectivity [lindex $CoordNums([lindex $atomnames 0]) end]

	# searching for surface or bulk atoms
	set bulkIDs($atm) {}
	set surfaceIDs($atm) {}
	foreach id [lindex $CoordNumLists($atm) 0] c [lindex $CoordNumLists($atm) 1] {
	    if {$c < $bulkConnectivity}  {
		lappend surfaceIDs($atm) $id
	    } elseif {$c == $bulkConnectivity} {
		lappend bulkIDs($atm) $id
	    } else {
		puts stderr "getType: Error in defining surface and bulk"
	    }
	}
    }

    return [ list [array get CoordNumLists ] [array get CoordNums ] [array get surfaceIDs ] [array get bulkIDs ] ]
    
}


