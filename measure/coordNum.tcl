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
# @param sel1 : main selection from which neighbors/coordNums are computed
# @param sel2 : selection of neighbor atoms
# @param r : cutoff of neighbors
# @param start, end : first and last considered frames. If if equals a simplified output is returned, see RETURN below
# @param coordNum (optional, default=F, return cordinations numbers instead of index of neighbor atoms
# @param nopairs (optional, default=F, do not count pairs twice)
# @return if start != end (working with trajectory)
#             if coordNum==F -> \[list  (atomids) \[array(frame) (neigh\_atomids) \]\]
#             if coordNum==T -> \[list  (atomids) \[array(frame) (coordnum) \]\]
#         if start == end (working with single frame)
#             if coordNum==F -> \[list  (atomids) (neigh\_atomids) \]
#             if coordNum==T -> \[list  (atomids) (coordnum) \]
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
 - sel1 : main selection from which neighbors/coordNums are computed
 - sel2 : selection of neighbor atoms
 - r : cutoff of neighbors
 - start, end : first and last considered frames. If if equals a simplified output is returned, see RETURN below
 - coordNum (optional, default=F, return cordinations numbers instead of index of neighbor atoms
 - nopairs (optional, default=F, do not count pairs twice)
 
 RETURN if start != end (working with trajectory)
             if coordNum==F -> \[list  (atomids) \[array(frame) (neigh\_atomids) \]\]
             if coordNum==T -> \[list  (atomids) \[array(frame) (coordnum) \]\]
         if start == end (working with single frame)
             if coordNum==F -> \[list  (atomids) (neigh\_atomids) \]
             if coordNum==T -> \[list  (atomids) (coordnum) \]
"
}

# Compute id of neighbor atms of coord atoms at certain frame,
# defined to be called by ::utiltools::measure::NeighAtms and not directly 
proc ::utiltools::measure::computeNeighAtms {molID id_list sel2 r frame coordNum nopairs} {

	set neighb {}
        for {set i 0}  {$i < [llength $id_list]} {incr i} {

	# define selection
	    set id [lindex $id_list $i]
	    
	    if {$nopairs} {
		set sel_string "($sel2) and (within $r of index $id) and not (index  [lrange $id_list 0 $i] )"
	    } else {
		set sel_string "($sel2) and (within $r of index $id) and not (index $id)"
	    }
	    
	    # get neigbours
	    set tmp [atomselect $molID $sel_string frame $frame]
	    set nn [$tmp num]
	    
	    # store neighbours
	    if { [llength $nn] == 0 } {
		# check existence of neighbours
		$tmp delete
		continue
	    } elseif {$coordNum} {
#		lappend mainGrp $id
		lappend neighb $nn
		$tmp delete
	    } else {
		set tmp [atomselect $molID $sel_string frame $frame]
#		lappend mainGrp $id
		lappend neighb [$tmp get index]
		$tmp delete
	    }

	}

	return $neighb

    
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

    # checking whether a trajectory is considered
    if {$start != $end} {
	puts "::utiltools::measure::NeighAtms working with trajectory" 
	set trajNeigh T
    } else {
	puts "::utiltools::measure::NeighAtms working with single frame"
	set trajNeigh F
    }

    # list of atom IDs
    set atsel1 [atomselect $molID $sel1]
    set id_list1 [$atsel1 get index]
    
    # search for neighbors

    if { $trajNeigh } {
	# working with trj
	array unset neighatm
	array set neighatm {}
	for {set frame $start} {$frame <= $end} {incr frame} {
	    set neighatm($frame) [::utiltools::measure::computeNeighAtms $molID $id_list1 $sel2 $r $frame $coordNum $nopairs]
	}		  
	return [list $id_list1 [array get neighatm]] 
    } else {
	# only one frame (start==end)
	set neighatm [::utiltools::measure::computeNeighAtms $molID $id_list1 $sel2 $r $start $coordNum $nopairs]
 	return [list $id_list1 $neighatm] 
    }
    

}
