## \file randomCube.tcl --
#
#  Return points randomly placed on a cube with an optional minimal distance between points
#
# Salvatore Cosseddu 2013-2016
#
# SYNOPSIS:
#   ::utiltools::random::randomSphere N center r <cutoff (0)> <maxIter (100)> 
#
# OPTIONS
# @param N               : number of points
# @param center		 : Sphere center (es. \{1. 1. 1.\}
# @param d		 : cube size (es. \{10. 10. 10.\}
# @param <cutoff (0)>	 : minimal distance between points
# @param <maxIter (100)> : Max number of trials to apply cutoff 
# @return List of cooordinates of the sphere points \{ \{x1 y1 z1\} ... \{xN yN zN\} \}
#
# Ex.
# set ligID  \[mol new "formeate.xyz"\]
# set N 50
# set ligStructure formeate.xyz
# set center {0 0 0}
# set d {10 10 10}
# set cutoff 5
# set Sel_lig_Main "name C O"
# set Sel_lig2 "name H"
# # Determine coordinates of ligands
# set ligandCoords \[::utiltools::random::randomCube $N $center $c $cutoff \]
# # creating new molecule with ligands
# # set ligID \[mol new $ligStructure waitfor all\]
# set ligMolID \[::utiltools::mol::clone $ligID all $ligandCoords "C" $ligandCoords $Sel_lig_Main $Sel_lig2\]


package provide utiltools 3.0

namespace eval utiltools {
    namespace eval random {
	# declaring namespace
	namespace export randomSphere
    }
}

proc ::utiltools::random::randomCube {N center d  {cutoff {0}} {maxIter {100}}} {
    # Cube points are random points on different surfaces.
    # Surfaces are initially random selected, then point on the sphere is picked
    
    # remove overlapping positions
    if {$cutoff > 0} {
	set removePoints T
	puts "::utiltools::quantumdot::ligandsLocate remove overlaps (d < $cutoff)"
    } elseif { $cutoff == 0} {
	set removePoints F
    } else {
	puts stderr "::utiltools::quantumdot::ligandsLocate cutoff must >= 0"
    }

#    namespace import ::tcl::mathfunc::rand
    expr srand([clock seconds])

    # a vector with the template coordinates of point for the different faces 
    lassign $d dx dy dz
    lassign [vecscale 0.5 $d] dhx dhy dhz
    lassign $center xc yc zc
    set facez1 [expr { $zc-$dhz }]
    set facez2 [expr { $zc+$dhz }] 
    set facey1 [expr { $yc-$dhy }] 
    set facey2 [expr { $yc+$dhy }] 
    set facex1 [expr { $xc-$dhx }] 
    set facex2 [expr { $xc+$dhx }] 

    proc getCoord {c d dh} {
	expr {rand()*$d + $c - $dh}
    }
    
    set PickRandomPosCommands [ list \
				    {list [getCoord $xc $dx $dhx] [getCoord $yc $dy $dhy] $facez1 } \
				    {list [getCoord $xc $dx $dhx] [getCoord $yc $dy $dhy] $facez2 } \
				    {list [getCoord $xc $dx $dhx] $facey1                  [getCoord $zc $dz $dhz] } \
				    {list [getCoord $xc $dx $dhx] $facey2                  [getCoord $zc $dz $dhz] } \
				    {list $facex1                  [getCoord $yc $dy $dhy] [getCoord $zc $dz $dhz] } \
				    {list $facex2                  [getCoord $yc $dy $dhy] [getCoord $zc $dz $dhz] } \
				   ]

    set Coords {}
    for {set lig 0} {$lig < $N} {incr lig}  {

	set testN T
	set Iter 0 
	while { $testN } {

	    # randomly pick one of the command in $faces and execute it
	    set ranPos [eval [lindex $PickRandomPosCommands [::utiltools::random::randRangeInt 0 6]]]

	    # exiting loop
	    if { $removePoints && [llength $Coords] > 0 } {
		#  removing overlapping
		foreach p $Coords {
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
		    
	lappend Coords $ranPos
    }

    return $Coords
}

# # test 
# set ligID  [mol new "formeate.xyz"]

# set N 50
# set ligStructure formeate.xyz
# set center {0 0 0}
# set d {10 10 10}
# set cutoff 5
# set Sel_lig_Main "name C O"
# set Sel_lig2 "name H"

# # Determine coordinates of ligands
# set ligandCoords [::utiltools::random::randomCube $N $center $c $cutoff ]
    
# # creating new molecule with ligands
# # set ligID \[mol new $ligStructure waitfor all\]
# set ligMolID [::utiltools::mol::clone $ligID all $ligandCoords "C" $ligandCoords $Sel_lig_Main $Sel_lig2]
