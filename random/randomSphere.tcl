## \file randomSphere.tcl --
#
#  Return points randomly placed on a sphere. Tcl implementation of
#  "Marsaglia, G. "Choosing a Point from the Surface of a Sphere." Ann. Math. Stat. 43, 645-646, 1972."
#  with an optional minimal distance between points
#
# Salvatore Cosseddu 2013-2016
#
# SYNOPSIS:
#   ::utiltools::random::randomSphere N center r <cutoff (0)> <maxIter (100)> 
#
# OPTIONS
# @param N               : number of points
# @param center		 : Sphere center
# @param r		 : radius
# @param <cutoff (0)>	 : minimal distance between points
# @param <maxIter (100)> : Max number of trials to apply cutoff 
# @return List of cooordinates of the sphere points \{ \{x1 y1 z1\} ... \{xN yN zN\} \}
#
# Ex.
#  ::utiltools::random::randomSphere 100 {0 0 0} 50 5 ;# 100 points on a sphere of 50 radius, centered on (0,0,0), mimal distance 5 


package provide utiltools 3.0

namespace eval utiltools {
    namespace eval random {
	# declaring namespace
	namespace export randomSphere
    }
}

proc ::utiltools::random::randomSphere {N center r {cutoff {0}} {maxIter {100}}} {

    # remove overlapping positions
    if {$cutoff > 0} {
	set removePoints T
	puts "::utiltools::quantumdot::ligandsLocate remove overlaps (d < $cutoff)"
    } elseif { $cutoff == 0} {
	set removePoints F
    } else {
	puts stderr "::utiltools::quantumdot::ligandsLocate cutoff must >= 0"
    }
    
    expr srand([clock seconds]) 
    set r2 [expr {$r*$r}]
        
    set ligsiteCoords {}
    for {set lig 0} {$lig < $N} {incr lig}  {
	# Marsaglia, G. "Choosing a Point from the Surface of a Sphere." Ann. Math. Stat. 43, 645-646, 1972.
		
	# sphere coords
	set x1 [expr {rand()*2. -1.}]

	set testN T
	set Iter 0 
	while { $testN } {
	    set x2 [expr {rand()*2 -1}]
	    set x1_2 [expr {$x1*$x1}]
	    set x2_2 [expr {$x2*$x2}]

	    # testing exit from while loop
	    if { ($x1_2 + $x2_2) >= 1.} {continue}
	    
	    set x [expr {2 * $x1 * sqrt(1 - $x1_2 - $x2_2)}]
	    set y [expr {2 * $x2 * sqrt(1 - $x1_2 - $x2_2)}]
	    set z [expr {1-2*($x1_2 + $x2_2)}]

	    # centering and scaling the sphere
	    set ranPos [vecadd [vecscale $r [list $x $y $z]] $center]

	    # exiting loop
	    if { $removePoints && [llength $ligsiteCoords] > 0 } {
		#  removing overlapping
		foreach p $ligsiteCoords {
		    # exit only if no overlap found
		    if {[set ov [vecdist $p $ranPos]] <= $cutoff} {
			puts "::utiltools::quantumdot::ligandsLocate removing overlap $ov"
			set testN T
			break
		    } else {
			set testN F
		    }
		}
	    } else {
		# exit loop
		set testN F
	    }

	    # safety exit
	    if {$Iter == $maxIter} {
		puts stderr "::utiltools::quantumdot::ligandsLocate maxIter reached, try reduce or remove cutoff"
		return -code 1
	    }

	    incr Iter
	    
	}
		    
	lappend ligsiteCoords $ranPos
    }

    return $ligsiteCoords
}
