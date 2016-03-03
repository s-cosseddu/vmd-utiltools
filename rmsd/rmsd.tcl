## \file rmsd.tcl --
#
#   Few function to compute RMSD:
#   rmsd-r: Compute RMSD of atoms as a function of distance (with respect of the reference)
#           write 2 outfiles (rmsd<sel>-r<...>.dat) time series and averages
#
# Salvatore Cosseddu 2013-2015
#
# SYNOPSIS:
#   ::utiltools::rmsd::rmsd-r molID r dr selection <molIDreference (molID)> <plot (TRUE)>
#
# OPTIONS
# @param molID	 
# @param selection
# @param molIDreference (optional, default == molID, ref always set to frame 0
#                       of molIDreference, selection in molID and molIDreference must have same indices) 
# @param plot boolean, plot result?
# @return \[list <r> <averaged rmsds>\]
#

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval rmsd {
	# declaring namespace
	namespace export rmsd-r trajrmsd
    }
}


proc ::utiltools::rmsd::utilrmsd { frame selection reference } {
    $selection frame $frame
    $selection move [measure fit $selection $reference]
    return [measure rmsd $selection $reference]
}


proc ::utiltools::rmsd::rmsd-r {molID r dr {selection {protein and backbone}} {molIDreference {}} {plot {TRUE}}} { 

    set outname [regsub -all { } $selection "_" ]
    
    # set default moiID
    if {[llength $molIDreference] == 0} {
	set molIDreference $molID
    }

    # set COM of ref to define distance r
    set reference [atomselect $molIDreference "($selection)" frame 0]
    lassign [measure center $reference weight mass] xcom ycom zcom
    $reference delete

    set n_frames [molinfo $molID get numframes]
    
    # binning selections
    array set ref {}
    set r_list {}
    # half dr for x axis
    #set dr_2 [vecscale 0.5 $dr]
    for {set dis $dr} {$dis <= $r} {set dis [expr $dis + $dr]} {
	set dis_low [expr {$dis - $dr}]
	set ref($dis) [atomselect $molIDreference "($selection) and (sqrt((x-$xcom)**2 +(y-$ycom)**2+(z-$zcom)**2) >= $dis_low) and (sqrt((x-$xcom)**2 +(y-$ycom)**2+(z-$zcom)**2) < $dis)" frame 0]  
	set idx($dis) [$ref($dis) get index]
	
	if { [llength $idx($dis)] == 0 } {
	    puts "at $dis no from COM"
	    set ref($dis) -1 
	} else {
	    puts "at $dis from COM: $idx($dis)"
	    set sel($dis) [atomselect $molID "index $idx($dis)"]
	}
  	lappend r_list $dis
	set rmsdlist($dis) {}
    }

    set out  [open "rmsd_${outname}-r_time.dat" w]
    set timelist {}
    for {set frame 0} {$frame < $n_frames} {incr frame} {
	puts -nonewline $out "$frame\t"
	foreach dis $r_list {
	    if {$ref($dis) != -1} {
		set rmsdtmp [::utiltools::rmsd::utilrmsd $frame $sel($dis) $ref($dis)] 
	    } else {
		set rmsdtmp 0
	    }
	    puts -nonewline $out "$rmsdtmp\t"
	    lappend rmsdlist($dis) $rmsdtmp 
	}

	# carriage in outfile
	puts $out ""
	
	if {[expr {fmod($frame,1000)}] == 0} { puts "frame: $frame"}
	lappend timelist $frame
    }
    close $out
    
    set avrmsdlist {}
    foreach dis $r_list {
	lappend avrmsdlist [vecmean $rmsdlist($dis)]
    }
    
    if {$plot} {
	#	multiplot -x $timelist -y $rmsdlist -title "RMSD" -lines -linewidth 3 -marker point -plot
	multiplot -x $r_list -y $avrmsdlist -title "RMSD" -lines -linewidth 3 -marker point -plot
    }

    set result [list $r_list $avrmsdlist]
    ::utiltools::array2ascii $result rmsd_${outname}-r.dat
    return $result

}

proc ::utiltools::rmsd::trajrmsd {molID {selection {protein and backbone}} {molIDreference {}} {cutlast {0}} {cutbeg {0}} {plot {TRUE}}} { 

    
    if {[llength $molIDreference] == 0} {
	set molIDreference $molID
    }

    if {$cutlast >0 || $cutbeg >0 } {
	puts "Ignoring cutlast $cutlast cutbeg $cutbeg"
	if {[llength $molIDreference] == 0} {
	    set molIDreference $molID
	}

	# only interesting for protein, don't consider start and end of protein
	set backbone [atomselect $molID "protein and backbone and noh"]
	if {$cutlast >0 } {
	    set excluded_res [lrange [lsort -unique -integer [$backbone get resid]] end-$cutlast end] 
	} else {
	    set excluded_res 1000000
	}
	
	if {$cutbeg >0 } {
	    concat $excluded_res [lrange [lsort -unique -integer [$backbone get resid]] 0 $cutbeg] 
	} else {
	    concat $excluded_res 1000001
	}

	$backbone delete
	set ref [atomselect $molIDreference "($selection) and noh and not resid $excluded_res" frame 0]
	set sel [atomselect $molID "($selection) and noh and not resid $excluded_res"]
    
    } else {
	puts "No cutbeg or cutlast"
	set ref [atomselect $molIDreference "($selection) and noh" frame 0]
	set sel [atomselect $molID "($selection) and noh"]
    }

    set n_frames [molinfo $molID get numframes]

    set rmsdlist {}
    set timelist {}
    for {set frame 0} {$frame < $n_frames} {incr frame} {
	set rmsdtmp [::utiltools::rmsd::utilrmsd $frame $sel $ref] 
	lappend timelist $frame
	lappend rmsdlist $rmsdtmp 
	if {[expr {fmod($frame,1000)}] == 0} { puts "frame: $frame"}
    }

    $sel delete
    $ref delete
    
    if {$plot} {
	multiplot -x $timelist -y $rmsdlist -title "RMSD" -lines -linewidth 3 -marker point -plot
    }

    return [list $timelist $rmsdlist]

}
