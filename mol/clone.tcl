## \file clone.tcl --
#
# Clone a system, or part of it, on user-defined positions. It creates a new VMD mol with the cloned objects.   
# 
# es.  											       
# ::utiltools::mol::clone molID sel poslist <segpref (C)> <orientlist (none)> <orientSel1 (none)> <orientSel2 (none)> 
# OPTIONS
# @param molID : molecule to be cloned 
# @param sel : atom selection 
# @param poslist : list of cartesian coordinates for the COM of the cloned systems
# @param <segpref (C)> : prefix of segnames of the newly created Mol
# @param <orientlist (none)> : list of directions used for orienting the cloned systems 
# @param <orientSel1 (none)> : first selection to define orienting vector 
# @param <orientSel2 (none)> : second selection to define orienting vector 
# @return newMolID

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval mol {
	# declaring namespace
	namespace export clone
    }
}

proc ::utiltools::mol::clone {molID sel poslist {segpref {C}} {orientlist "none"} {orientSel1 {}} {orientSel2 {}}} {

    # get number of copies
    set ncopies [llength $poslist]
    
    # take original selection 
    set atmsel [atomselect $molID "$sel"]

    # original position
    # set allposlist [linsert $poslist 0 [$atmsel get {x y z}]]
    
    # number of atoms
    set natm_sel [$atmsel num]
    set natm_tot [expr {$natm_sel * $ncopies}];	# of all copies
    
    # create vmd molecule
    set mol -1
    if {[catch {mol new atoms $natm_tot} mol]} {
        vmdcon -err "::utiltools::mol::clone could not create new molecule: $mol"
        return -1
    } else {
        animate dup $mol
    }
    mol rename $mol cloned$molID

    # preparing orient variable
    if {[string match $orientlist "none"]} {
	set orient_mol F
	puts "Clones are not oriented"
    } else {
	if {[string match $orientlist "random"]} {
	    # random orientation
	    set vector1 {0. 0. 1.}
	    set orientlist [::utiltools::random::RandomMatrix 3 $ncopies]
	    puts "Clones are oriented randomly"
	} else {
	    set TMPatSel1 [atomselect $molID $orientSel1]
	    set TMPatSel2 [atomselect $molID $orientSel2]
	    set vector1 [vecsub [measure center $TMPatSel2 weight mass] [measure center $TMPatSel1 weight mass]]
	    $TMPatSel1 delete
	    $TMPatSel2 delete
	    
	    puts "Clones are oriented with respect of $vector1"
	}
	set orient_mol T
	
    }
	
	
    # MAIN ----
    
    set cloneID 0
    set atmIDLow 0
    set atmIDHigh [expr {$natm_sel - 1} ] 
    foreach pos $poslist {

	set newsel [atomselect $mol "index $atmIDLow to $atmIDHigh"]

	# copy reference properties into the new selection
	::utiltools::mol::copy $atmsel $newsel

	# set a different segname for each copy
	$newsel set segname $segpref$cloneID

	# move to place
	$newsel moveby [vecsub $pos [measure center $newsel weight mass ]]

	# orient
	if {$orient_mol} {
	    set orientation [lindex $orientlist $cloneID]
	    $newsel move [::utiltools::mod::orient $newsel $vector1 $orientation]
	}
	
        $newsel delete
	incr cloneID
	incr atmIDLow  $natm_sel
	incr atmIDHigh $natm_sel
    }

    $atmsel delete

    mol reanalyze $mol
    return $mol
}
