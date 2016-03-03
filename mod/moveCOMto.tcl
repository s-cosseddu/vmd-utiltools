## \file moveCOMto.tcl --
#
#  move a group of atom (moving_selection) in order to move the COM of a second selection (COM_selection) to a given position
#
# Salvatore Cosseddu 2013
#
# SYNOPSIS:
#      utiltools::mod::moveCOMto <molID> <moving_selection> <COM> \[<COM_selection (default moving_selection)\]
#

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval mod {
	namespace export moveCOMto
    }
}

proc ::utiltools::mod::moveCOMto { {molID {}} {sel_string {}} COM {COM_string {}} } {

    if {![ llength $molID ] ||
	![ llength $sel_string ] } { 
	error "
 utiltools::mod::moveCOMto <molID> <moving_selection> <COM> \[<COM_selection (default moving_selection)\] > "
    }

        if {[ llength $COM_string ] == 0} { 
	    set COM_string $sel_string
	}

    
    set sel [atomselect $molID "$sel_string"]
    set ref [atomselect $molID "$COM_string"]
  
    set center_of_mass_ref [measure center $ref weight mass ]
    
    # moving residues
    set disp [vecsub $COM $center_of_mass_ref]
    $sel moveby $disp

    puts "::utiltools::mod::moveCOMto: $COM_string moved by $disp"  
   
    $sel delete
    $ref delete

}
