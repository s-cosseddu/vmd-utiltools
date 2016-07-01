## \file coordNum.tcl --
#
#  Set of tools to compute neighbor atoms and coordination atoms 
#
# Salvatore Cosseddu 2013-2015
#
# FUNCTION:
#   NeighAtms -
#   Search neighbours of sel1 atoms in sel2 atoms  
#   if required compute coordination number (coordNum T)
#   or do not repeat pairs nopairs (useful for sums)
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

# FUNCTION:
#   AtmXcoordNum -
#   Sort atoms according to the number of neighbor atoms belonging to a given atom selection and within a range r.
#   Implementation is independent from ::utiltools::measure::NeighAtms and therefore faster if
#   more detailed information are not required.
# 
#   For flexibility (array are not flexible in tcl),
#   output is \[list (coordnums1 coordnums2 ) \[list \{atomids_list1\} \{atomids_list1\} ...\]\]
#   which maps into the simple two dimensional array
#        coordnums1         coordnums2         ...
#   1  atomids_list1,1   atomids_list2,1       ...
#   2  atomids_list1,2   atomids_list2,2	 ...
#   3  atomids_list1,3   atomids_list2,3       ...
#   ...   ...                 ...              ...
#
# SYNOPSIS:
#   ::utiltools::measure::AtmXcoordNum <molID> <sel1> <sel2> <r> <start> <end> \[<print (F)\]
#
# OPTIONS
# @param molID	 
# @param sel1 : main selection from which neighbors/coordNums are computed
# @param sel2 : selection of neighbor atoms
# @param r : cutoff for searching neighbors
# @param start, end : first and last considered frames. If if equals a simplified output is returned, see RETURN below
# @return \[list (coordnums1 coordnums2 ) [list {atomids_list1} {atomids_list1} ...] (see description)
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

proc ::utiltools::measure::usage_AtmXcoordNum {} {
puts " FUNCTION:
   AtmXcoordNum -
   Sort atoms according to the number of neighbor atoms belonging to a given atom selection and within a range r.
   Implementation is independent from ::utiltools::measure::NeighAtms and therefore faster if
   more detailed information are not required.
 
   For flexibility (array are not flexible in tcl),
   output is \[list (coordnums1 coordnums2 ) \[list \{atomids_list1\} \{atomids_list1\} ...\]\]
   which maps into the simple two dimensional array
        coordnums1         coordnums2         ...
   1  atomids_list1,1   atomids_list2,1       ...
   2  atomids_list1,2   atomids_list2,2	 ...
   3  atomids_list1,3   atomids_list2,3       ...
   ...   ...                 ...              ...

 SYNOPSIS:
   ::utiltools::measure::AtmXcoordNum <molID> <sel1> <sel2> <r> <start> <end> \[<print (F)\]

 OPTIONS
 - molID	 
 - sel1 : main selection from which neighbors/coordNums are computed
 - sel2 : selection of neighbor atoms
 - r : cutoff for searching neighbors
 - start, end : first and last considered frames. If if equals a simplified output is returned, see RETURN below
 return \[list (coordnums1 coordnums2 ) [list {atomids_list1} {atomids_list1} ...] (see description)
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
		lappend neighb $nn
	    } else {
		lappend neighb [$tmp get index]
	    }
	    $tmp delete
	    
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
    $atsel1 delete
    
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

proc ::utiltools::measure::computeNeighAtmslists {molID id_list sel2 r frame} {

    # output is \[list (coordnums1 coordnums2 ) [list {atomids_list1} {atomids_list1} ...]


    set coordNumsList {}
    
    for {set i 0}  {$i < [llength $id_list]} {incr i} {
	
	# define selection
	set id [lindex $id_list $i]
	set sel_string "($sel2) and (within $r of index $id) and not (index $id)"
	# get neigbours
	set tmp [atomselect $molID $sel_string frame $frame]

	# add to a list of ids
	set nn [$tmp num]
	lappend CNlist$nn $id
	#list of coordnums 
	lappend coordNumsList $nn 
	$tmp delete
    	
    }

    # 
    set CNs [lsort -integer -unique $coordNumsList] 
    foreach nn $CNs {
	lappend CNall [set CNlist$nn]
    }

    return [list $CNs $CNall] 
    
}

proc ::utiltools::measure::AtmXcoordNum {{molID {}} sel1 sel2 r start end} {
    # sort atoms according to their coordination number
    # For flexibility (array are not flexible in tcl),
    # output is \[\[list (coordnums1 coordnums2 )\] \[list \{atomids_list1\} \{atomids_list1\} ...\]\]
    # which maps into the simple two dimensional array
    #      coordnums1         coordnums2         ...
    # 1  atomids_list1,1   atomids_list2,1       ...
    # 2  atomids_list1,2   atomids_list2,2	 ...
    # 3  atomids_list1,3   atomids_list2,3       ...
    # ...   ...                 ...              ...
    # 
    # array is used for trajectories (start != end):
    # array($frame) == \[\[list (coordnums1 coordnums2 )\] \[list \{atomids_list1\} \{atomids_list1\} ...\]\]
    # 
    
    if {[llength $molID] == 0 || [string match $molID "-h"] } {
	::utiltools::measure::usage_AtmXcoordNum
	return
    }
    
    # checking whether a trajectory is considered
    if {$start != $end} {
	puts "::utiltools::measure::AtmXcoordNum working with trajectory" 
	set trajNeigh T
    } else {
	puts "::utiltools::measure::AtmXcoordNum working with single frame"
	set trajNeigh F
    }

    # list of atom IDs
    set atsel1 [atomselect $molID $sel1]
    set id_list1 [$atsel1 get index]
    $atsel1 delete
    
    # search for neighbors

    if { $trajNeigh } {
	# working with trj
	array unset neighatm
	array set neighatm {}
	for {set frame $start} {$frame <= $end} {incr frame} {
	    set neighatm($frame) [::utiltools::measure::computeNeighAtmslists $molID $id_list1 $sel2 $r $frame]
	}		  
	return [array get neighatm] 
    } else {
	# only one frame (start==end)
	set neighatm [::utiltools::measure::computeNeighAtmslists $molID $id_list1 $sel2 $r $start]
 	return $neighatm 
    }
    

}

proc ::utiltools::measure::printAtmXcoordTs {{arrname {}} outfile} {

    package require struct

    if {[llength $arrname] == 0 || [string match $arrname "-h"] } {
	puts "print ts from from ::utiltools::measure::AtmXcoordNum 
usage:  ::utiltools::measure::printAtmXcoordTs <ts array from AtmXcoordNum> <output filename>"
	return
    }
    
    upvar 1 $arrname cnarr

    if { [catch {open $outfile w} outfid] } {
	puts stderr "::utiltools::measure::AtmXcoordNum Could not open $outfile for writing"
	return -code 1
    }

    set frames [array name cnarr]

    # checking cn,
    set CNs {}
    puts "checking coordination numbers, may take long"
    foreach f $frames {
	set CNs [lsort -unique -integer [::struct::set union [lindex $cnarr($f) 0] $CNs]]
    }

    puts "writing ts"
    puts $outfid "# $CNs"

    foreach f $frames {
	foreach c $CNs { 
	    set cnpos [lsearch -integer -exact  [lindex $cnarr($f) 0] $c]
	    if { $cnpos >= 0} {
		puts -nonewline $outfid "[llength [lindex $cnarr($f) 1 $cnpos]]\t"
	    } else {
		puts -nonewline $outfid "0\t"
	    }
	}
	puts $outfid ""
    }
    close $outfid

    return
    
}
