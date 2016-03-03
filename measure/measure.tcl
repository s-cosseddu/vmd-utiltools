## \file measure.tcl --
#
#  Additional useful measure functions
#
# Salvatore Cosseddu 2013
#
# Functions:
#  measureBox <molID> [sel (water)]
#      measure size of a selection
#
#  gettotcharge <molID> [sel (all)]
#      return total charge (charge information must be loaded) 
# 

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval measure {
	# declaring namespace
	namespace export measureBox gettotcharge
    }
}

proc utiltools::measure::measureBox {molID {sel {water}}} {
    #  measure size of a selection
    set tmpsel [atomselect $molID "$sel"]
    set bb [vecsub {*}[measure minmax $tmpsel]]
    $tmpsel delete 
    return $bb
}

proc utiltools::measure::gettotcharge {molID {sel {all}}} {
    set tmpsel [atomselect $molID "$sel"]
    set cc vecsum [$tmpsel get charge]
    $tmpsel delete 
    return $cc
}
