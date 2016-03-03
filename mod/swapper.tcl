## \file swapper.tcl --
#
#  swap position of two group of atoms
#
# Salvatore Cosseddu 2013
#
# SYNOPSIS:
#    utiltools::mod::swapper <molID> <selection1> <selection2> \[<output pdb>\]
#

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval mod {
	namespace export swapper
    }
}


proc ::utiltools::mod::swapper { {molID  {}} {sel1_string {}} {sel2_string {}} {outname {swapper.pdb}}} {

    if {![ llength $molID ] ||
	![ llength $sel1_string ] ||
	![ llength $sel2_string ] } { 
	error "
 utiltools swapper <molID> <selection1> <selection2> \[<output pdb>\]
     "
    }


    #    mol new $pdb
    # 
    #    regsub -all , $sel1_string { } sel1_string
    #     regsub -all , $sel2_string { } sel2_string
    puts "::utiltools::mod::swapper:
========================================
               swapping 
    $sel1_string 
                 and 
    $sel2_string
========================================
"
    # creating a representation to visualize swapping selections
    set new_rep [lindex [mol list $molID] 12]
    mol addrep top    
    mol modselect $new_rep $molID "($sel1_string) or ($sel2_string)"
    mol modstyle $new_rep $molID VDW 1.2 12.0
    #############

    set sel1 [atomselect $molID "$sel1_string"]
    set sel2 [atomselect $molID "$sel2_string"]

    if { [llength [lsort -unique [$sel1 get resid]]] != 1 ||
	 [llength [lsort -unique [$sel2 get resid]]] != 1 } {
	error "the procedure can swap only single residues"
    }
    
    set center_of_mass1 [measure center $sel1 weight mass ]
    set center_of_mass2 [measure center $sel2 weight mass ]
    
    # moving residues
    $sel1 moveby [vecsub $center_of_mass2 $center_of_mass1]
    $sel2 moveby [vecsub $center_of_mass1 $center_of_mass2]

    set all [atomselect $molID all]
    $all writepdb $outname
    puts "::utiltools::mod::swapper: written $outname"

    $all  delete
    $sel1 delete
    $sel2 delete

}
