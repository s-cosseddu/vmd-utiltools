## \file orient.tcl --
#
# Provide trans matrix to orient a selection according to a vector
# Adapted from Orient http://www.ks.uiuc.edu/Research/vmd/script_library/scripts/orient/
# 
# Copyright of the owner for the original part

# es.  											       
# ::utiltools::orient atselCOM vector1 vector2 offset
# OPTIONS                                                       				       
# @param molID	 
# @param atselCOM atom selection (made with atomselect) of the part of the system oriented      					       
# @param x <angle> y <angle> z <angle>,   								       
#   rotation is performed around axes and angles here selected, the angles are in degrees,         
#   only one is needed									       
# @return null

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval mod {
	namespace export orient
    }
}


# rotate a selection about its COM, taking <vector1> to <vector2>
# e.g.: orient $sel [lindex $I 2] {0 0 1}
# (this aligns the third principal axis with z)
proc ::utiltools::mod::orient {atselCOM vector1 vector2 {offset {}}} {

    set COM [measure center $atselCOM weight mass]
    
    set vec1 [vecnorm $vector1]
    set vec2 [vecnorm $vector2]

    # compute the angle and axis of rotation
    set rotvec [veccross $vec1 $vec2]
    set sine   [veclength $rotvec]
    set cosine [vecdot $vec1 $vec2]
    set angle [expr atan2($sine,$cosine)]
    
    # return the rotation matrix
    if {[llength $offset] == 0} {
	return [trans center $COM axis $rotvec $angle rad]
    } else {
	return [trans center $COM axis $rotvec $angle rad offset $offset]
    }
}
