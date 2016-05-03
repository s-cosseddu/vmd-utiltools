## \file common.tcl --
#
# Functions common to mol procedures.
# 
# ::utiltools::mol::copy CopyTo CopyFrom (cpylist)
# copy properties between two atomselections
# default for cpylist is {name type mass charge radius element x y z resname resid chain}

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval mol {

	proc ::utiltools::mol::copy {CopyFrom CopyTo {cpylist {name type mass charge radius element x y z resname resid chain}}} {
	    # copy properties between two atomselections 
	    
	    $CopyTo set $cpylist [$CopyFrom get $cpylist]
	    return 
	}

    }
}
