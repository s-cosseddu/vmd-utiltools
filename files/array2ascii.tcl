## \file array2ascii.tcl --
#
#  Write arbitrary shaped tcl arrays to arrays to ascii files
#
# Salvatore Cosseddu 2013
#
# SYNOPSIS:
#   array2ascii <tclarray>  <output_file> [opts ...]
#
# OPTIONS
# @param tcllist
# @param outname
# @param (optional) title <title_line> 
# @param (optional) form <tcl_formatString (defalut %12.8e) 
# @param (optional) delimiter <del_string (default \t)
# @return null
#

package provide utiltools 3.0

namespace eval utiltools {
    namespace eval files {
	namespace export array2ascii
    }
}

proc ::utiltools::files::array2ascii {{tcllist {}} {outname {}} args} {

        
    if {![llength $tcllist] || ![llength $outname] } {
	puts "
DESCRIPTION:
   Print out an Ascii file from an arbitrary shaped tcl array

SYNOPSIS:
   array2ascii <tclarray>  <output_file> \[opts ...\]

OPTIONS
   \[title <title_line>\] 
   \[form <tcl_formatString (defalut %12.8e)>\] 
   \[delimiter <del_string (default \\t)> 
"
	return 
    }

    set out [open "$outname" w]

    set num_col [llength $tcllist]
    set num_row [llength [lindex $tcllist 0]]


    set count 1
    set form "%12.8e"
    set del "\t"
    set titleline false
    foreach opt $args {
	set value [lindex $args $count]
	switch -exact -- $opt {
	    title { 
		# writing in the output a titlename
		puts $out $value
	    }
	    form {
		set form $value
	    }
	    delimiter {
		set del $value 
	    }
	    
	}
	incr count
    }

    if {![string match $titleline "false"]} {
	puts $out $titleline
    }

    for {set row 0} {$row<$num_row} {incr row} { 
	set line {}
	for {set col 0} {$col<$num_col} {incr col} { 
	    puts -nonewline $out "[format "${form}%s" [lindex $tcllist $col $row] \t]"
	}
	# carriage
	puts -nonewline $out "\n"
    }

     close $out
}
