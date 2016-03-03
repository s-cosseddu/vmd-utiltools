## \file center.tcl --
#
#   Center the selection (default "all") of the molID molecule
#   according to the weight (default simple geometrical center) at
#   <frame>th frame (default now)
#
# Salvatore Cosseddu 2013-2015
#
# SYNOPSIS:
#   utiltools center <molID> \[<selection>\] \[<frame>\] \[<weight>\]
#
# OPTIONS
# @param molID	 
# @param selection
# @param frame	 (optional, default now) 
# @param weight  (optional, default none) 
# @return null
#

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval mod {
	namespace export center
    }
}

proc ::utiltools::mod::center { {molID {}} {selection {all}} {frame {now}} {weight {}} {verbose {F}}} {
    # checking which file will be centered
    # if the input is a psf-> psf and pdb will be centered
    # if the input is a pdb-> only the pdb will be centered
    #    set prefix [regsub -nocase .pdb $filename {}]

    # checking input
    if {![ llength $molID ]} { 
	puts stderr "
 utiltools center <molID> \[<selection>\] \[<frame (now)>\] \[<weight>\] \[<verbose (F)>\]
      center the selection (default \"all\") of the molID molecule according to the weight (default simple geometrical center) 
      at <frame>th frame (default now)
"
	return -code 1
    }

    if { $verbose } {
	puts "working with $selection $weight"
    }
    
    # selecting part will be in the center
    set sel [atomselect $molID $selection frame $frame]
    set all [atomselect $molID all frame $frame]

    
    # calculating -( magnitude of the translation )
    if {[llength $weight] == 0} {
	set oldcenter [measure center $sel]
    } else {
	set oldcenter [measure center $sel weight $weight]
    }
    
    # centering	
    $all moveby [vecinvert $oldcenter]
    if { $verbose } {
	puts "--------------------------------------------------------------------------------

                        mol $molID moved from 

            $oldcenter 
                                 to  
            [measure center $sel]

--------------------------------------------------------------------------------"
    }

    $sel delete
    $all delete

    return
}
