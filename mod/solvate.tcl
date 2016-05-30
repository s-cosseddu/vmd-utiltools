## \file solvate.tcl --
#
#  Quickly solvate any structure (no psf needed)  
#
# Salvatore Cosseddu 2013-2016

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval mod {
	# declaring namespace
	namespace export solvate
    }
}

proc ::utiltools::mod::solvate {molID boxsize solvent_file {outfile {"solvated.pdb"}} {cutoff {2.5}} {solv_box_side {"auto"}} {solv_segname {"SL"}}} {

    package require topotools

    # loading solvent box to be replicated
    set sbID [mol new $solvent_file waitfor all]

    # getting size of solvent box if not provided
    if {[string match $solv_box_side "auto"]} {
	if {[catch {lrange {*}[pbc get -molid $sbID] 0 2} solv_box_side]} {
	    puts stderr "Solvent file does not contain box informations"
	    return -code 1
	}
	puts $solv_box_side
    }

    if {[llength $boxsize] != 3 || [llength $solv_box_side] != 3 } {
	puts stderr "boxsize and solv_box_side must be a vector of 3 elements"
	return -code 1
    }
   
    # define origin of final solvent box
    set refSel [atomselect $molID all]
    set refCenter [measure center $refSel]
    set hbox [vecscale 0.5 $boxsize]
    set minbox [vecsub $refCenter $hbox]
    set maxbox [vecadd $refCenter $hbox]
    set origin [vecadd $minbox [vecscale 0.5 $solv_box_side]]    

    # create grid
    set boxsize_int {}
    foreach i $boxsize j $solv_box_side {
	lappend boxsize_int [expr {int(ceil($i/$j))}]
    }
    #::utiltools::common::grid origin sizes spaces
    set coords [::utiltools::common::grid $origin $boxsize_int $solv_box_side]

    # replicate solvent box on the grid, to the bigger solvent box 
    set bigsbID [::utiltools::mol::clone $sbID all $coords $solv_segname]

    set molSolID [::TopoTools::mergemols [list $molID $bigsbID]]

    # deleting overlapping
    #
    set Segname_list {}
    set SegN [::tcl::mathop::* {*}$boxsize_int]
    for {set i 0} {$i < $SegN} {incr i} {
	lappend Segname_list ${solv_segname}$i
    }


    mol bondsrecalc $molSolID
    topo guessangles
    topo guessdihedrals
    mol reanalyze $molSolID

    # replicated solv box
    lassign $minbox lx ly lz
    lassign $maxbox ux uy uz
    
    set cutID [::utiltools::mod::delete $molSolID "same residue as (segname $Segname_list and within $cutoff of (not segname $Segname_list))"]

    set solvatedID [::utiltools::mod::delete $cutID "same residue as not (x <= $ux and y <= $uy and z <= $uz and x >= $lx and y >= $ly and z >= $lz)" $outfile]

    
#     and (x <= $ux and y <= $uy and z <= $uz and x >= $lx and y >= $ly and z >= $lz))
    
    $bigsbSel delete
    $refSel delete
    mol delete $sbID
    mol delete $bigsbID
    mol delete $molSolID
    mol delete $cutID
    
    return $solvatedID

}


# test
# source "../common/grid.tcl"
# cd
# cd tmp

# set molID [mol new "/Users/salvatore/tmp/delete.pdb"]
# set boxsize {100 100 100}
# set solvent_file "/Volumes/Backup-2-VU/salvatore/lavoro/projects/quantumDots/Zeger/2-hexyldecanoic_acid/mk_structure/From_SPHERE_randomization/common/DCM3P_boxrel.pdb"
# set outfile "solvated.pdb"
# set solv_box_side "auto"
# set solv_segname "SL"
# set cutoff 3

# mol bondsrecalc $solvatedID
# topo retypebonds
# topo guessangles
# mol reanalyze $solvatedID
# $tmp writepsf ${outfile}.psf
# mol delete all
# $tmp delete
