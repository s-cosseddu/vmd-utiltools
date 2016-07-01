## \file coatQD.tcl --
#
# Transform external layer of a QD to create a coated QD
#
# Salvatore Cosseddu 2013-2015
#
# SYNOPSIS:
#   ::utiltools::quantumdot::coatQD <molID> <FromCoreSpecies> <ToShellSpecies> <secNeighDis> <ShellLayers>
# 
# example 
# set molID [mol new "./Cd336Se297_78Cl_3nm.xyz"]
# set FromCoreSpecies {Cd Se}
# set ToShellSpecies {Pb S}
# set secNeighDis {5.35 5.35}
# set ShellLayers 2
# ::utiltools::quantumdot::coatQD $molID $FromCoreSpecies $ToShellSpecies $secNeighDis $ShellLayers


package provide utiltools 3.0

namespace eval utiltools {
    namespace eval quantumdot {
	# declaring namespace
	namespace export coatQD
    }
}

proc ::utiltools::quantumdot::coatQD {molID FromCoreSpecies ToShellSpecies secNeighDis ShellLayers} {


    for {set l 0} {$l < $ShellLayers} {incr l} {
	
	foreach FromSp $FromCoreSpecies ToSp $ToShellSpecies d $secNeighDis {
	    
	    lassign [::utiltools::measure::AtmXcoordNum $molID "name $FromSp" "name $FromSp" $d 0 0] cns idsList
	    set surfIds [join [lrange $idsList 0 end-1]]
	    
	    # transform surface atoms to new species 
	    set shsel [atomselect $molID "index $surfIds"]
	    $shsel set name $ToSp
	    $shsel set element $ToSp
	    $shsel set segname "SH$l"
	    $shsel delete

	}
    }

    ::utiltools::files::writesel $molID coated.xyz all 

    return
    
}

# example 
# set molID [mol new "./Cd336Se297_78Cl_3nm.xyz"]
# set FromCoreSpecies {Cd Se}
# set ToShellSpecies {Pb S}
# set secNeighDis {5.35 5.35}
# set ShellLayers 2

# ::utiltools::quantumdot::coatQD $molID $FromCoreSpecies $ToShellSpecies $secNeighDis $ShellLayers
