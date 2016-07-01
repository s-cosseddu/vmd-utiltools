## \file rotate.tcl --
#
# Perform a rotation around selected axes on a selection of a pdb file                            
# es.  											       
# rotate top "all"  x -15 z 45 							       
# OPTIONS                                                       				       
# @param molID	 
# @param selection, select what part of the system will be rotate      					       
# @param x <angle> y <angle> z <angle>,   								       
#   rotation is performed around axes and angles here selected, the angles are in degrees,         
#   only one is needed									       
# @return null

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval mod {
	namespace export rotate
    }
}

proc ::utiltools::mod::usage_rotate {} { 
		
		puts "                                                                              
 ========================================================================================================\n\n\
 PROCEDURE                                                                                             \
 \n\t rotate,											       \
 \n\t Perform a rotation around selected axes on a selection of a pdb file                            \
 \n\n\t es.  											       \
 \n\t rotate top \"all\"  x -15 z 45 							       \
 \n\n OPTIONS                                                       				       \
 \n\t filename,                                                					       \
 \n\t\t name of the pdb files containing the deleting atoms (the extension must be explicitily .pdb),  \
 \n\t selection,                  								       \
 \n\t\t select what part of the system will be rotate      					       \
 \n\t x <angle> y <angle> z <angle>,   								       \
 \n\t\t rotation is performed around axes and angles here selected, the angles are in degrees,         \
 \n\t\t only one is needed									       \
 \n\n												       
  =====================================================================================================
 "
	    }


proc ::utiltools::mod::rotate {molID selection args} {
    # checking input

    if {[llength $molID] == 0 ||
	[llength $selection] == 0 ||
	[llength $args] == 0  } {
	::utiltools::mod::usage_rotate
	return
    }    

    set test [ regexp {^[xyz]$} [lindex $args 0]]
    set testtype [string is double [lindex $args 1]]
    
    if { $test != 1 || $testtype != 1 } { 
	puts "\
======================================== 
            error in $args!
======================================== "
	::utiltools::mod::usage_rotate
	return
    }
    
    # selecting part will be in the center
    set sel [atomselect top "$selection"]
    # selection all
    set all [atomselect top "all"]

    # rotating
    foreach {axe value} $args { 
	set transax [transaxis $axe $value]
	$sel move $transax
    }
    
    $all delete
    $sel delete
}

