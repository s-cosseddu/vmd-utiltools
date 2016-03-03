## \file distance.tcl --
#
#  procs to measure distances 
#
# Salvatore Cosseddu 2013
#
# FUNCTION:
#    distance -- compute distance between two selections
# SYNOPSIS:
#    utiltools::measure::distance <molID> sel1 sel2 \[frame (now)\] \[weight (null)\] 
# 
# FUNCTION:
#    distance_traj -- compute distance between two selections over the trajectory
# SYNOPSIS:
#    utiltools distance_traj <molID>  <selection1> <selection1> \[options...\] 
# OPTIONS
#    weight <value> (i.g. mass), first <first frame to be considered (default 0)>, last <last frame to be considered (default num frames)> 

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval measure {
	namespace export distance distance_traj
    }
}

proc ::utiltools::measure::distance { {molID {}} {selstring1 {}} {selstring2 {}} {frame {now}} {weight {}}} {

    global env

    if {![llength $molID] || ![llength $selstring1] || ![llength $selstring2]} {

	error "
DESCRIPTION:
   compute distance between two selections

SYNOPSIS:
   utiltools distance <molID>  <selection1> <selection1> \[frame (default now\] \[weight\] 

"

    }

    set sel1 [atomselect $molID $selstring1 frame $frame]
    set sel2 [atomselect $molID $selstring2 frame $frame]

    if {[info exists env(UTILDEBUG)] && $env(UTILDEBUG)==1} {
	puts "computing distance between:
    center of $weight 
1:"
	foreach i [$sel1 get {segname resid name}]  {
	    puts "$i"
	}
	puts "2:"
	foreach i [$sel2 get {segname resid name}] {
	    puts "$i"
	}
    }

    if {![llength $weight]} {
	set cent_sel1 [measure center $sel1]
	set cent_sel2 [measure center $sel2]
    } else {
	set cent_sel1 [measure center $sel1 weight $weight]
	set cent_sel2 [measure center $sel2 weight $weight]
    }

    set dist [veclength [vecsub $cent_sel1 $cent_sel2]]

    $sel1 delete
    $sel2 delete
    return $dist

}

proc ::utiltools::measure::distovertraj {start last {weight {}}} {
    
    upvar sel1 selection1
    upvar sel2 selection2

    set framelist {}
    set dist {}

    # for efficiency if is out of the loop and no eval is used
    if {![llength $weight]} {
	for {set frame $start} { $frame < $last } {incr frame} {
	    lappend framelist $frame 
	    $selection1 frame $frame
	    $selection2 frame $frame
	    set cent_sel1 [measure center $selection1]
	    set cent_sel2 [measure center $selection2]
	    lappend dist [veclength [vecsub $cent_sel1 $cent_sel2]]
   
	}
    } else {
	for {set frame $start} { $frame < $last } {incr frame} {
	    
	    lappend framelist $frame 
	    $selection1 frame $frame
	    $selection2 frame $frame	
	    set cent_sel1 [measure center $selection1 weight $weight]
	    set cent_sel2 [measure center $selection2 weight $weight]

	    lappend dist [veclength [vecsub $cent_sel1 $cent_sel2]]
	    
	}
    }
    
    return [list $framelist $dist]

    
}


##################################################
##################################################

proc ::utiltools::measure::distance_traj { {molID {}} {selstring1 {}} {selstring2 {}} args} {

    global env

    if {![llength $molID] || ![llength $selstring1] || ![llength $selstring2]} {

	error "
DESCRIPTION:
   compute distance between two selections over the trajectory

SYNOPSIS:
   utiltools distance_traj <molID>  <selection1> <selection1> \[options...\] 
 
OPTIONS

   weight <value> (i.g. mass), first <first frame to be considered>, last <last frame to be considered>

"
    }    

    # reading additional options 
    set weight {}
    set start 0 
    set last [molinfo $molID get numframes]
    foreach {opt value} $args {
	switch -exact -- $opt {
	    weight { 
		set weight $value
	    }
	    first {
		set first $value
	    }
	    last {
		set last [expr {$value + 1}] 
	    }
	    
	}
    }

    if {![llength $molID] || ![llength $selstring1] || ![llength $selstring2]} {

	error "
DESCRIPTION:
   compute distance between two selections

SYNOPSIS:
   utiltools distance <molID>  <selection1> <selection1> \[frame (default now\] \[weight\] 

"

    }

    puts "working on $selstring1"
    set sel1 [atomselect $molID $selstring1]
    puts "and $selstring2"
    set sel2 [atomselect $molID $selstring2]

    if {[info exists env(UTILDEBUG)] && $env(UTILDEBUG)==1} {
	puts "computing distance between:
    center of $weight 
1:"
	foreach i [$sel1 get {segname resid name}]  {
	    puts "$i"
	}
	puts "2:"
	foreach i [$sel2 get {segname resid name}] {
	    puts "$i"
	}
    }

    puts "Computing distances..."
    set diststats [distovertraj $start $last $weight]
    
    $sel1 delete
    $sel2 delete
    return $diststats

}
