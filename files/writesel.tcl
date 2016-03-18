## \file writesel.tcl --
#       
#  SYNOPSIS                                                                                            
#  writesel <output_filename> <selection>

# OPTIONS
# @param output file name,
# @param selection of atom (i.g. name OH2)
# @return null
#

package provide utiltools 3.0

namespace eval utiltools {
    # declaring namespace
    namespace eval files {
	# declaring namespace
	namespace export writesel
    }
}


proc ::utiltools::files::writesel {outname selection} {

    set extension [regsub . [file extension $outname] {} ]
    puts "outname :: $outname
extension :: $extension"
    
    set writing [atomselect top "($selection)"]
    # writing new file
    $writing write$extension $outname
    $writing delete
    mol new ${outname}

}
