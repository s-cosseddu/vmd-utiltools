## \file measure.tcl --
#
#  Useful function to compute radial distribution functions
#
# Salvatore Cosseddu 2016
#
# Functions:
#  rdf-com <molID> <selection> <ref_sel> <radius> <delta_r> \[<first_frame> (0)\] \[<end> (-1)\] [<rho> (1.)\]
#          measure RDF from the center of mass of ref_sel   

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval rdf {
	# declaring namespace
	namespace export rdf-com
    }
}

proc ::utiltools::rdf::compute_rdf_CM {start n_frame n_bin radius delta_r} {

    variable ref 
    variable sele
    variable n_gr

    set gr [::math::linearalgebra::mkVector [expr {$n_bin}] 0.0]
    set n_gr 0

    for {set frame $start} {$frame<$n_frame} {incr frame} {
	  # updating selection

	  $ref frame $frame
	  $sele frame $frame
	  
	  # defining the center of mass from where the rdf will be calculated
	  set center [measure center $ref weight mass]
	  set coor [$sele get {x y z}]
	
	  foreach i $coor {
	      set r_i [::math::linearalgebra::norm [::math::linearalgebra::sub $center $i]]

	      # getting only those within radius from the ref_sel	      
	      if {$r_i <= $radius} {

		  set int_r_i [expr {int($r_i/$delta_r)}]

		  # sampling in gr vector
		  ::math::linearalgebra::setelem gr $int_r_i [expr {[::math::linearalgebra::getelem $gr $int_r_i]+1}]

	      }
	      
	  }
	  incr n_gr
      }

    return $gr

}

proc ::utiltools::rdf::rdf-com {molID selection ref_sel radius delta_r {first_frame {0}} {end {-1}} {rho {1.}}} {
  
    package require math::linearalgebra
    variable ref 
    variable sele
    variable n_gr
        
    puts "rdf_from_center_of_mass: computing rdf from center of mass $ref_sel"
    puts "rdf_from_center_of_mass: of $selection"

    set ref [atomselect $molID "$ref_sel"]
    set sele [atomselect $molID "$selection"]

    # modify the kind in order to avoid rounding problems
    set radius [expr {double($radius)}]
    set delta_r [expr {double($delta_r)}]
    set rho [expr {double($rho)}]

    set start $first_frame

    set n_bin [expr {int(double($radius)/double($delta_r))}]
    
    if {$end < 0 } {
	set n_frame [molinfo $molID get numframes]
    } else {
	set n_frame $end
    }
 
    
    # computing gr
    set gr [::utiltools::rdf::compute_rdf_CM $start $n_frame $n_bin $radius $delta_r]
	  
    puts " Normalisation..."

    # init variables
    set pi 3.14159265358979323846
    set norm_factor {}
    set r {}
    for {set bin 0} {$bin < $n_bin} {incr bin} {
	lappend r [expr {$delta_r*(double($bin)+0.5)}]

 	# Value of normalisation factor Volume_bin * n of sampling
	# norm factor is computed in one step for efficiency (tcl is not made for pure calculations)
	# I'm using normalisation factor inverse to be able to use vecscale (it might be slighty more efficient)
#	lappend norm_factor [expr {1./(double($n_gr) * (4./3.) * $pi * (pow($bin+1,3) - pow($bin,3)) * pow($delta_r,3)) } ]
	set r_i_piu_uno [expr {($bin+1)*$delta_r}]
	set r_i [expr {($bin)*$delta_r}]
	lappend norm_factor [expr {1./(double($n_gr) * (4./3.) * $pi * ($r_i_piu_uno*$r_i_piu_uno*$r_i_piu_uno - $r_i*$r_i*$r_i))}]
 	
    }

    set normgr [vecmul $norm_factor $gr]
    set rhonormgr [vecscale [expr {1./$rho}] $normgr]
    set unnormgr [vecscale [expr {1./double($n_gr)}] $gr]
    

    $sele delete
    $ref delete
    unset ::utiltools::rdf::ref 
    unset ::utiltools::rdf::sele
    unset ::utiltools::rdf::n_gr
    
    return [list $r $normgr $rhonormgr $unnormgr]

}

