## \file coordNum.tcl --
#
# Search neighbours of sel1 atoms in sel2 atoms 
# if required compute coordination number (coordNum T)
# or do not repeat pairs nopairs (useful for sums)
#
# Salvatore Cosseddu 2013-2015
#
# SYNOPSIS:
#   ::utiltools::measure::NeighAtms <molID> <sel1> <sel2> <r> <start> <end> \[<coordNum F>\] \[<nopairs F>\]
#
# OPTIONS
# @param molID	 
# @param selection
# @param sel1
# @param sel2
# @param r
# @param start
# @param end
# @param coordNum (optional, default=F, return cordinations numbers instead of index of neighbor atoms
# @param nopairs (optional, default=F, do not count pairs twice)
# @return \[array(frame) (atomids) (neigh\_atomids) \]
#          or if coordNum==T \[array(frame) (atomids) (coordnum) \] 
#

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval measure {
	# declaring namespace
	namespace export NeighAtms
    }
}

proc ::utiltools::measure::usage_NeighAtms {} {

    puts stderr "Search neighbours of sel1 atoms in sel2 atoms 
 if required compute coordination number (coordNum T)
 or do not repeat pairs nopairs (useful for sums)

 Salvatore Cosseddu 2013-2015

 SYNOPSIS:
   ::utiltools::measure::NeighAtms <molID> <sel1> <sel2> <r> <start> <end> \[<coordNum F>\] \[<nopairs F>\]

 OPTIONS
 - molID	 
 - selection
 - sel1
 - sel2
 - r
 - start
 - end
 - coordNum (optional, default=F, return cordinations numbers instead of index of neighbor atoms
 - nopairs (optional, default=F, do not count pairs twice)
 return \[array(frame) (atomids) (neigh\_atomids) \]
          or if coordNum==T \[array(frame) (atomids) (coordnum) \] 
"
}

proc ::utiltools::measure::NeighAtms {molID sel1 sel2 r start end {coordNum F} {nopairs F}} {
    # search neighbours of sel1 atoms in sel2 atoms 
    # if required compute coordination number (coordNum T)
    # or do not repeat pairs nopairs (useful for sums)

    
    if {[llength $molID] == 0 ||
	[llength $sel1] == 0 ||
	[llength $sel2] == 0 ||
	[llength $r] == 0 ||
	[llength $start] == 0 ||
	[llength $end] == 0 } {
	::utiltools::quantumdot::usage_NeighAtms
	return
    }
    
    if { $coordNum && $nopairs } {
	puts stderr "coordNum and nopairs selected: error"
	return
    }
    
    # list of atom IDs
    set atsel1 [atomselect $molID $sel1]
    set id_list1 [$atsel1 get index]
    
    # search for neighbors
    array set neighatm {}
    set mainGrp {}
    set neighb {}

    for {set frame $start} {$frame <= $end} {incr frame} { 
        for {set i 0}  {$i < [llength $id_list1]} {incr i} {

	# define selection
	    set id [lindex $id_list1 $i]
	    
	    if {$nopairs} {
		set sel_string "(sel2) and (within $r of index $id) and not (index  [lrange $id_list 0 $i] )"
	    } else {
		set sel_string "(sel2) and (within $r of index $id) and not (index $id)"
	    }
	    
	    # get neigbours

	    # store neighbours
	    if { [llength $nn] == 0 } {
		# check existence of neighbours
		continue
	    } elseif {$coordNum} {
		set tmp [atomselect $molID $sel_string frame $frame]
		lappend mainGrp $id
		lappend neighb [$tmp num]
		$tmp delete
	    } else {
		set tmp [atomselect $molID $sel_string frame $frame]
		lappend mainGrp $id
		lappend neighb [$tmp get index]
		$tmp delete
	    }

	}
	
	set neighatm($frame) [list $mainGrp $neighb]
    }

    return [array get neighatm] 

}
