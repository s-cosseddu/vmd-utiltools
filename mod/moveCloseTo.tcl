## \file moveCloseTo.tcl --
#
#  move a group of atom at a given distance from a second one
#
# Salvatore Cosseddu 2013
#
# SYNOPSIS:
#     utiltools::mod::moveclose <molID> <moving_selection> <ref_selection> \[<distance from reference vector> (default {0.5 0.5 0.5})  \[<output pdb>\]
#

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval mod {
	namespace export moveCloseTo
    }
}

proc ::utiltools::mod::moveCloseTo { {molID {}} {sel_string {}} {ref_string {}} {displacement {1.5 1.5 1.5}} {outname {}}} {

    if {![ llength $molID ] ||
	![ llength $sel_string ] ||
	![ llength $ref_string ] } { 
	error "
 utiltools moveclose <molID> <moving_selection> <ref_selection> \[<distance from reference vector> (default {0.5 0.5 0.5})  \[<output pdb>\]
"
    }
    puts "::utiltools::mod::moveclose:
========================================
               moving
    $sel_string
    $displacement from   
    $ref_string 
    
========================================
"
    # creating a representation to visualize swapping selections
    set new_rep [lindex [mol list $molID] 12]
    mol addrep top    
    mol modselect $new_rep $molID "($sel_string) or ($ref_string)"
    mol modstyle $new_rep $molID VDW 1.2 12.0
    mol modcolor $new_rep $molID ColorID 6
    #############

    set sel [atomselect $molID "$sel_string"]
    set ref [atomselect $molID "$ref_string"]

    if { [llength [lsort -unique [$sel get resid]]] != 1 } {
	error "the procedure can move only single residues"
	
    }
    
    set center_of_mass [measure center $sel weight mass ]
    set center_of_mass_ref [measure center $ref weight mass ]
    
    # moving residues
    $sel moveby [vecsub [vecadd $center_of_mass_ref $displacement] $center_of_mass]

    if {[llength $outname] > 0} {
	set all [atomselect $molID all]
	$all writepdb $outname
	puts "::utiltools::mod::moveclose: written $outname"
	$all  delete
    }

    $sel delete
    $ref delete

}
