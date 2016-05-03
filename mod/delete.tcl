## \file delete.tcl --
#
#  Delete atoms given a selection
#
# Salvatore Cosseddu 2013
#
# SYNOPSIS:
#  quickly delete atoms  					       
#  es.                                                                                            
#  delete top "name OH2" 
#  delete 2 "name OH2" 1K4C.pdb (write to file)
# #
# OPTIONS
# @param  mol ID
# @param  selection
# @param  filename (optional)
#
# @return null
#

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval mod {
    # declaring namespace
	namespace export delete
    }
}

proc ::utiltools::mod::usage_delete {} {
	puts "
Delete atoms given a selection

SYNOPSIS:
 quickly delete atoms  					       
 es.                                                                                            
 delete top \"name OH2\" 
 delete 2 \"name OH2\" 1K4C.pdb (write to file)

OPTIONS
mol ID
selection
output filename (optional) default delete.pdb
"
}

proc ::utiltools::mod::delete {molID selection {outname {}}} {
        # checking input
    if {![ llength $molID ] || ![ llength $selection ]} {
	::utiltools::mod::usage_delete
    }

    if {[ llength $outname ] == 0 } {
	set outname /tmp/delete.pdb
    }

    ::utiltools::files::writesel $molID $outname "not ($selection)" 
    mol new ${outname}    
}
