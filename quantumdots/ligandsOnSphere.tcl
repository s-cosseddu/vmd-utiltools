package provide utiltools 3.0

namespace eval utiltools {
    namespace eval quantumdots {
	# declaring namespace
	namespace export ligandsOnSphere
    }
}


proc ::utiltools::quantumdots::ligandsOnSphere {ligID nligs center r Sel_lig_Main Sel_lig2 {cutoff {5}}} {

    # Determine coordinates of ligands
    set ligandCoords [::utiltools::random::randomSphere $nligs $center $r $cutoff]
    
    # creating new molecule with ligands
    # set ligID \[mol new $ligStructure waitfor all\]
    set ligMolID [::utiltools::mol::clone $ligID all $ligandCoords "C" $ligandCoords $Sel_lig_Main $Sel_lig2]

}

# test
# set nligs 50
# set ligStructure formeate.xyz
# set center {0 0 0}
# set r 25
# set Sel_lig_Main "name C O"
# set Sel_lig2 "name H"
# ::utiltools::quantumdot::ligandsOnSphere $nligs $ligStructure $center $r $Sel_lig_Main $Sel_lig2
