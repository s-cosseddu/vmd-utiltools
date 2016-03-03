## \file superimposer.tcl --
#
#   Superimpose two molecules (or the same molecule with respect of a
#   specific frame) and, if requested, return rmsd.
#
#   Salvatore Cosseddu 2013-2015
#
# SYNOPSIS:
#   utiltools::mod::superimposer selection molID_1 molID_2 \[<moving_mol_selection>\] \[<rmsd>\] \[<protein>\] 
#
# OPTIONS
# @param selection for superposition 
# @param molID_1 reference molecule. Optionally a frame can be provided, es. \{0 123\} (see details)
# @param molID_2 moving molecule. If equal to molID_1, a frame must be provided in molID_1.  	
# @param moving_mol_selection a different selection for molID_2  (optional, see details) 
# @param rmsd return rmsd? Boolean, optional, default F		     
# @param protein protein selection should be used? Boolean, optional, default F, see details
# @return null or rmsd
#
# DETAILS
# molID_1 (reference structure) can be provided as a list. In this
# case the second element is used to set the reference
# frame. Es. for \{0 123\} the superposition is performed with
# respect of the 123rd frame of molID 0.  If molID_1 is not a
# list, a superposition is performed on each frame of the
# trajectory of molID_1.
#
# Definition of the atom selection for moving atoms selection that is equal to <selection>
# unless the param moving_mol_selection is provided.
# In case of <protein>=T the application of moving_mol_selection=selection is a bit more complicated
# to allow superposition of different structures.
# 

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval mod {
	namespace export superimposer
    }
}

proc ::utiltools::mod::superimposer {selection molID_1 molID_2 {moving_mol_selection {}} {rmsd F} {protein F}} {
    
    
    ##
    # molID_1 (reference structure) can be provided as a list. In this
    # case the second element is used to set the reference
    # frame. Es. for \{0 123\} the superposition is performed with
    # respect of the 123rd frame of molID 0.  If molID_1 is not a
    # list, a superposition is performed on each frame of the
    # trajectory of molID_1
    #
    lassign $molID_1 ref_mol ref_frame
    if { [molinfo $ref_mol get numframes] != 1 } {  
	set superimpose_traj 1
    } else {
	set superimpose_traj 0
    }

    #    checking if a refernce frame is present
    if { [llength $ref_frame] != 0 } {
	if { $ref_mol == $molID_2 && [llength $ref_frame] ==0 } {
	    puts stderr "molID_1 == molID_2, provide a frame to molID_1"
	    return -code 1
	}
	set superimpose_traj 0
	set ref_frame 0
    } 
    
    # create atom selection for reference
    set reference [atomselect $ref_mol "$selection" frame $ref_frame ]

    ##
    # Definition of the atom selection for moving atoms selection that is equal to <selection>
    # unless the param moving_mol_selection is provided.
    # In case of <protein>=T the application of moving_mol_selection=selection is a bit more complicated
    # to allow superposition of different structures.
    #
    if ![llength $moving_mol_selection] {
	if { $protein } {
	    set moving_mol_selection "resid [$reference get resid] and resname [$reference get resname] and name [$reference get name] and segname [$reference get segname]"
	} else {
	    set moving_mol_selection "$selection"
	}
    }
    set moving_mol [atomselect $molID_2 "$moving_mol_selection"]
    #puts "moving [$moving_mol get index] with respect to [$reference get index]"
    set moving_all [atomselect $molID_2 "all"]
    # -----------------------------------



    # ------------- MAIN LOOP ------------
    set nframes [molinfo $molID_2 get numframes]
    set rmsdlist {}
    for {set frame 0} {$frame < $nframes} {incr frame} {
	
	if $superimpose_traj { $reference frame $frame }
	$moving_mol frame $frame
	$moving_all frame $frame
	$moving_all move [measure fit $moving_mol $reference]
	if {$rmsd} {lappend rmsdlist [measure rmsd $moving_mol $reference]}
    }

    # cleaning memory
    $reference  delete
    $moving_mol delete
    $moving_all delete

    if {$rmsd} {
	return $rmsd
    } else {
	return 1
    }

}
