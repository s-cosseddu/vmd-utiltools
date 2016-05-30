## \file grid.tcl --
#
#  Return points placed on a cubic grid. 


package provide utiltools 3.0

namespace eval utiltools {
    namespace eval common {
	# declaring namespace
	namespace export grid
    }
}

proc ::utiltools::common::grid {origin sizes spaces} {

    lassign $origin x0 y0 z0
    lassign $sizes xd yd zd
    lassign $spaces dx dy dz

    set gg {}
    for {set i 0} {$i < $xd} {incr i} {
	set x [expr {$x0 + $i*$dx}]
	for {set j 0} {$j < $yd} {incr j} {
	    set y [expr {$y0 + $j*$dy}]
	    for {set k 0} {$k < $zd} {incr k} {
		set z [expr {$z0 + $k*$dz}]
		lappend gg [list $x $y $z]
	    }
	}
    }
    return $gg
    
}


# set dimensions \{2 2 2\}
# set nx 3
#     set orep \[::tcl::mathop::* \{*\}$sizes\]
	      
#     set nx \[length $dimensions\]
#     set Arr \{\}

#     for \{ set i 0\} \{ $i < $nx \} \{incr i\} \{
# 	set d \[lindex $sizes $i\]
# 	set s \[lindex $spaces $i\]

# 	set orep \[expr \{$orep / $d\}\]
# 	set vec \{\}
# 	for \{ set j 0\} \{ $j < $orep \} \{ incr j\} \{
# 	    lappend vec $i
# 	\}
# 	lappend Arr $vec
#     \}
